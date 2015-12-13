# Asks the robot about the versions of its software stack components.
class SpheroPwn::Commands::GetDeviceMode < SpheroPwn::Command
  def initialize
    super 0x02, 0x44, nil
  end

  # @see {SpheroPwn::Command#response_class}
  def response_class
    SpheroPwn::Commands::GetDeviceMode::Response
  end
end

# The versions of a robot's software stack.
class SpheroPwn::Commands::GetDeviceMode::Response < SpheroPwn::Response
  # @return {Symbol} the device's mode; can be :normal or :user_hack
  attr_reader :mode

  # @see {SpheroPwn::Response#initialize}
  def initialize(code_byte, sequence_byte, data_bytes)
    super

    if code == :ok
      @mode = case data_bytes[0]
      when 0x00
        :normal
      when 0x01
        :user_hack
      else
        :unknown
      end
    else
      @mode = :error
    end
  end
end
