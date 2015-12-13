# Asks the robot about the versions of its software stack components.
class SpheroPwn::Commands::SetDeviceMode < SpheroPwn::Command
  def initialize(mode)

    mode_byte = case mode
    when :normal
      0x00
    when :user_hack
      0x01
    else
      raise ArgumentError, "Unimplemented mode #{mode.inspect}"
    end

    super 0x02, 0x42, [mode_byte]
  end

  # @see {SpheroPwn::Command#response_class}
  def response_class
    SpheroPwn::Commands::SetDeviceMode::Response
  end
end

# The versions of a robot's software stack.
class SpheroPwn::Commands::SetDeviceMode::Response < SpheroPwn::Response
end
