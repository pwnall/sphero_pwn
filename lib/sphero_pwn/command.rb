# Superclass for the command messages going from the computer to the robot.
class SpheroPwn::Command
  # @param {Number} device_id the virtual device ID for the command
  # @param {Number} command_id the command number; unique within a virtual
  #   device ID
  # @param {String} data_bytes extra data in the command; can be nil if no
  #   extra data will be transmitted
  def initialize(device_id, command_id, data)
    @device_id = device_id
    @command_id = command_id
    @data = data
    @sop2 = 0xFF
  end

  # Clears the command bit that asks for a response.
  def no_response!
    @sop2 &= 0xFE
    self
  end

  # Clears the command bit that resets the client inactivity timeout.
  def no_timeout_reset!
    @sop2 &= 0xFD
    self
  end

  # @return {Boolean} true if the command will receive a response
  def expects_response?
    (@sop2 & 0x01) != 0
  end

  # @param {Number} the sequence number to be embedded in the command
  def to_bytes(sequence)
    data_length = @data.nil? ? 1 : 1 + @data.length
    data_length = 0xFF if data_length > 0xFF
    bytes = [0xFF, @sop2, @device_id, @command_id, sequence, data_length]
    bytes.concat @data unless @data.nil?

    sum = 0
    bytes.each { |byte| sum = (sum + byte) }
    bytes.push(((sum - 0xFF - @sop2) & 0xFF) ^ 0xFF)
    bytes.pack('C*')
  end

  # The class used to parse the response for this command.
  #
  # Subclasses should override this method.
  #
  # @return {Class<SpheroPwn::Response>} the class that will be instantiated
  #   when this command's response is received
  def response_class
    SpheroPwn::Response
  end
end
