require 'rubyserial'
require 'thread'

# Communication channel with a robot.
#
# This is a light abstraction over the Bluetooth serial port (RFCONN) used to
# talk to a robot.
class SpheroPwn::Channel
  # Opens up a communication channel with a robot.
  #
  # @param {String} rfconn_path the path to the device file connecting to the
  #   robot's Bluetooth RFCONN service
  # @param {Hash} options
  def initialize(rfconn_path, options = {})
    @connect_timeout = options[:connect_timeout] || 15
    @read_timeout = options[:read_timeout] || 30
    @read_backoff = options[:read_backoff] || 0.2
    @send_queue = Queue.new

    @port = connect rfconn_path, @connect_timeout
    @send_thread = spawn_sending_thread @send_queue, @port
  end

  # @param {String} bytes a binary-encoded string of bytes to be sent to the
  #   robot over the RFCONN port
  # @return {Channel} self
  def send_bytes(bytes)
    @send_queue.push bytes
    self
  end

  # @param {Integer} byte_count the number of bytes to be read from the RFCONN
  #   port
  # @return {String} a binary-encoded string of bytes retrieved from the RFCONN
  #   port; the string may have fewer bytes than requested
  def recv_bytes(byte_count)
    buffer = ''.encode Encoding::BINARY

    last_byte_at = Time.now
    loop do
      new_bytes = @port.read byte_count - buffer.length
      buffer.concat new_bytes
      break if buffer.length == byte_count

      if new_bytes.empty?
        break if Time.now - last_byte_at >= @read_timeout
        sleep @read_backoff
      else
        last_byte_at = Time.now
      end
    end
    buffer
  end

  # Gracefully shuts down the communication channel with the robot.
  #
  # @return {Channel} self
  def close
    @send_queue.push :close
    @port.close
    self
  end

  # Connects to an RFCONN serial port.
  #
  # @param {String} rfconn_path the path to the device file connecting to the
  #   robot's Bluetooth RFCONN service
  # @param {Number} timeout the number of seconds to retry connecting when
  #   getting EBUSY
  # @return {Serial} the connected port
  def connect(rfconn_path, timeout)
    give_up_at = Time.now + timeout
    port = nil
    while port.nil?
      begin
        port = Serial.new rfconn_path, 115200, 8
      rescue RubySerial::Exception => e
        raise e unless e.message == 'EBUSY'
        raise e if Time.now >= give_up_at
      end
    end
    port
  end
  private :connect

  # Creates a thread that reads data from a queue and writes it to an IO.
  #
  # The thread expects to pop String instances from the queue, and will
  # write them to the IO. When the thread pops the :close symbol, it stops
  # executing.
  #
  # @param {Queue} send_queue the queue that the tread will read data from
  # @param {IO} io the IO that the data bytes will be written to
  # @return {Thread} the newly created thread
  def spawn_sending_thread(send_queue, io)
    Thread.new do
      loop do
        bytes = send_queue.pop
        break if bytes == :close

        io.write bytes
      end
    end
  end
  private :spawn_sending_thread
end
