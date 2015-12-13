require 'thread'

# A communication session with a robot.
class SpheroPwn::Session
  # @param {Channel} channel the byte-level communication channel with the
  #   robot
  def initialize(channel)
    @channel = channel


    # Must be acquired to change any of the values below.
    @sequence_lock = Mutex.new
    # Maps sequence numbers to responses expected from the server.
    @pending_responses = {}
    # Sweeps the space of valid sequence numbers.
    @last_sequence = 0
  end


  # Terminates this session and closes the underlying communication channel.
  #
  # @return {Session} self
  def close
    @channel.close
    self
  end

  # @param {Command} command the command to be sent
  # @return {Session} self
  def send_command(command)
    sequence = 0
    if command.expects_response?
      @sequence_lock.synchronize do
        sequence = alloc_sequence
        @pending_responses[sequence] = command.response_class
      end
    end

    bytes = command.to_bytes sequence
    @channel.send_bytes bytes
    self
  end

  # Reads messages from the robot until a response is received.
  #
  # @return {Response} the response received
  def recv_until_response
    loop do
      message = recv_message
      if message && message.kind_of?(SpheroPwn::Response)
        return message
      end

      # TODO(pwnall): customizable sleep interval
      sleep 0.05
    end
  end

  # Reads a message from the robot.
  #
  # This method blocks until a message is available. The method can be called
  # in a loop on a dedicated thread, and will synchronize correctly with
  # {Session#send_command}.
  #
  # @return {Response, Async} the response read from the channel; can be nil if
  #   no message was received or if the checksum verification failed
  def recv_message
    start_of_packet = @channel.recv_bytes 1
    return nil unless start_of_packet && start_of_packet.ord == 0xFF

    packet_type = @channel.recv_bytes 1
    return nil unless packet_type
    case packet_type.ord
    when 0xFF
      read_response
    when 0xFE
      read_async_message
    else
      nil
    end
  end

  # Finds an unused sequence number.
  #
  # Sending a command that requires a response allocates a sequence number.
  # Receiving the required response frees up the sequence number.
  #
  # The caller should own the sequence_lock mutex.
  #
  # @return {Number} a sequence number that can be used for a command; the
  #   sequence number is not considered to be allocated until the caller
  #   inserts it as a key in @pending_commands
  def alloc_sequence
    begin
      @last_sequence = (@last_sequence + 1) & 0xFF
    end while @pending_responses.has_key? @last_sequence
    @last_sequence
  end
  private :alloc_sequence

  # Reads the response to a command from the channel.
  #
  # This assumes that the start-of-packet was already read and indicates a
  # command response.
  #
  # @return {Response} the parsed response
  def read_response
    header_bytes = @channel.recv_bytes(3).unpack('C*')
    response_code, sequence, data_length = *header_bytes
    return nil unless data_length

    # It may seem that it'd be better to look up the sequence number and bail
    # early if we don't find it. However, in order to avoid misleading error
    # messages, we don't want to touch anything in the message until we know
    # that the checksum is valid.
    data_bytes = @channel.recv_bytes(data_length).unpack('C*')
    checksum = data_bytes.pop
    unless self.class.valid_checksum?(header_bytes, data_bytes, checksum)
      return nil
    end

    klass = @sequence_lock.synchronize { @pending_responses.delete sequence }
    return nil if klass.nil?

    klass.new response_code, sequence, data_bytes
  end
  private :read_response

  # Reads an asynchronous message from the channel.
  #
  # This assumes that the start-of-packet was already read and indicates an
  # asynchronous message.
  #
  # @return {Response} the parsed response
  def read_async_message
    header_bytes = @channel.recv_bytes(3).unpack('C*')
    class_id, length_msb, length_lsb  = *header_bytes
    return nil unless length_msb && length_lsb

    # It may seem that it'd be better to look up the sequence number and bail
    # early if we don't find it. However, in order to avoid misleading error
    # messages, we don't want to touch anything in the message until we know
    # that the checksum is valid.
    data_length = (length_msb << 8) | length_lsb
    data_bytes = @channel.recv_bytes(data_length).unpack('C*')
    checksum = data_bytes.pop
    unless self.class.valid_checksum?(header_bytes, data_bytes, checksum)
      return nil
    end

    SpheroPwn::Asyncs.create class_id, data_bytes
  end
  private :read_async_message

  # Checks if a message's checksum matches its contents.
  #
  # @param {Array<Number>} header_bytes the header semantics differ between
  #   command responses and async messages, but both have 3 bytes
  # @param {Array<Number>} data_bytes
  def self.valid_checksum?(header_bytes, data_bytes, checksum)
    sum = 0
    header_bytes.each { |byte| sum += byte }
    data_bytes.each { |byte| sum += byte }
    checksum == ((sum & 0xFF) ^ 0xFF)
  end
end
