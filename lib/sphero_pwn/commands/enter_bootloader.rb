# Asks the robot to jump into its bootloader.
class SpheroPwn::Commands::EnterBootloader < SpheroPwn::Command
  def initialize
    super 0x00, 0x30, nil
  end

  # @see {SpheroPwn::Command#response_class}
  def response_class
    SpheroPwn::Commands::EnterBootloader::Response
  end
end

# The response to an enter bootloader command.
class SpheroPwn::Commands::EnterBootloader::Response < SpheroPwn::Response
end
