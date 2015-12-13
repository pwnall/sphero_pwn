# Asks the robot's bootloader if a flash page is blank.
#
# This command is only valid when the robot is executing the bootloader.
class SpheroPwn::Commands::IsPageBlank < SpheroPwn::Command
  # @param {Number} page_number the flash page that the command will ask the
  #   robot to look at
  def initialize(page_number)
    if page_number > 255
      raise ArgumentError, "Page number #{page_number} exceeds 255"
    end
    super 0x01, 0x05, [page_number]
  end

  # @see {SpheroPwn::Command#response_class}
  def response_class
    SpheroPwn::Commands::IsPageBlank::Response
  end
end

# The response to a boot main application command.
class SpheroPwn::Commands::IsPageBlank::Response < SpheroPwn::Response
  # @return {Boolean} true if the flash memory page is blank
  attr_reader :is_blank
  alias_method :is_blank?, :is_blank

  # @see {SpheroPwn::Response#initialize}
  def initialize(code_byte, sequence_byte, data_bytes)
    super

    if code == :ok
      @is_blank = data_bytes[0] > 0
    else
      @is_blank = nil
    end
  end
end
