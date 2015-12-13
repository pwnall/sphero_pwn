# Obtains the robot's configuration flags that persist across power cycles.
class SpheroPwn::Commands::GetPermanentFlags < SpheroPwn::Command
  def initialize
    super 0x02, 0x36, nil
  end

  # @see {SpheroPwn::Command#response_class}
  def response_class
    SpheroPwn::Commands::GetPermanentFlags::Response
  end

  # @return {Hash<Number, Symbol>} symbolic values for the returned flags
  FLAGS = {
    0x01 => :no_sleep_while_charging,
    0x02 => :vector_drive,
    0x04 => :no_leveling_while_charging,
    0x08 => :tail_led_always_on,
    0x10 => :motion_timeouts,
    0x20 => :demo_mode,
    0x40 => :light_double_tap,
    0x80 => :heavy_double_tap,
    0x100 => :gyro_max_async,
  }.freeze
end

# The robot's configuration flags that persist across power cycles.
class SpheroPwn::Commands::GetPermanentFlags::Response < SpheroPwn::Response
  # @return {Hash<Symbol, Boolean>} maps developer-friendly flag names to
  #   whether the corresponding flags are set
  attr_reader :flags

  # @see {SpheroPwn::Response#initialize}
  def initialize(code_byte, sequence_byte, data_bytes)
    super

    @flags = {}
    if code == :ok
      flags_number = data_bytes[0, 4].pack('C*').unpack('N').first
      SpheroPwn::Commands::GetPermanentFlags::FLAGS.each do |mask, name|
        @flags[name] = (flags_number & mask) != 0
      end
    end
  end
end
