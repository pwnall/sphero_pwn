# Asks the robot to echo this message.
class SpheroPwn::Commands::Ping < SpheroPwn::Command
  def initialize
    super 0x00, 0x01, nil
  end

  # @see {SpheroPwn::Command#response_class}
  def response_class
    SpheroPwn::Commands::Ping::Response
  end
end

# The response to an echo command.
class SpheroPwn::Commands::Ping::Response < SpheroPwn::Response
end
