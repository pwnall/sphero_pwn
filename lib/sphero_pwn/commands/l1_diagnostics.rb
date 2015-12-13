# Asks the robot to send ASCII diagnostic data.
class SpheroPwn::Commands::L1Diagnostics < SpheroPwn::Command
  def initialize
    super 0x00, 0x40, nil
  end

  # @see {SpheroPwn::Command#response_class}
  def response_class
    SpheroPwn::Commands::L1Diagnostics::Response
  end
end

# The response to an L1 diagnostics command.
class SpheroPwn::Commands::L1Diagnostics::Response < SpheroPwn::Response
end
