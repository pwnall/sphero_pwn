# Superclass for all messages sent from the robot in response to commands.
class SpheroPwn::Response
  # @return {Symbol} the command's response
  attr_reader :code

  # @return {Number} the sequence number matching the response to its command
  attr_reader :sequence

  # @return {Array<Number>} the additional payload bytes in the response; this
  #   array is frozen
  attr_reader :data_bytes

  # Parses a response to a command.
  #
  # @param {Number} code_byte the response code number
  # @param {Number} sequence_byte the sequence number matching the response to
  #   its command
  # @param {Array<Number>} data_bytes the additional response payload; can be
  #   empty, cannot be nil; the constructor takes ownership of the array and
  #   freezes it
  def initialize(code_byte, sequence_byte, data_bytes)
    @code = RESPONSE_CODES[code_byte] || :unknown
    @sequence = sequence_byte
    @data_bytes = data_bytes.freeze
  end

  # @return {Hash<Integer, Symbol>} maps error codes to symbols
  RESPONSE_CODES = {
    0x00 => :ok,  # Command succeeded.
    0x01 => :generic_error,  # General, non-specific error.
    0x02 => :bad_checksum,  # Received checksum failure.
    0x03 => :got_fragment,  # Received command fragment.
    0x04 => :bad_command,  # Unknown command ID.
    0x05 => :unsupported,  # Command currently unsupported.
    0x06 => :bad_message,  # Bad message format.
    0x07 => :invalid_param,  # Parameter value(s) invalid.
    0x08 => :exec_failure,  # Failed to execute command.
    0x09 => :bad_device,  # Unknown Device ID.
    0x0A => :ram_busy,  # Generic RAM access needed but it is busy.
    0x0B => :bad_password,  # Supplied password incorrect.
    0x31 => :low_battery,  # Voltage too low for reflash operation.
    0x32 => :bad_page,  # Illegal page number provided.
    0x33 => :flash_fail, # Page did not reprogram correctly.
    0x34 => :main_app_corrupt,  # Main Application corrupt.
    0x35 => :timed_out,  # Msg state machine timed out.
  }.freeze
end
