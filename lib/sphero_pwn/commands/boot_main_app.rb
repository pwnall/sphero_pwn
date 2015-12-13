# Asks the robot's bootloader to boot the main application.
#
# This command is only valid when the robot is executing the bootloader.
class SpheroPwn::Commands::BootMainApp < SpheroPwn::Command
  def initialize
    super 0x01, 0x04, nil
  end

  # @see {SpheroPwn::Command#response_class}
  def response_class
    SpheroPwn::Commands::BootMainApp::Response
  end
end

# The response to a boot main application command.
class SpheroPwn::Commands::BootMainApp::Response < SpheroPwn::Response
end
