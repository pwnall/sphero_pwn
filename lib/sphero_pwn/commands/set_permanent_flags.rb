# Sets the robot's configuration flags that persist across power cycles.
class SpheroPwn::Commands::SetPermanentFlags < SpheroPwn::Command
  # @param {Hash<Symbol, Boolean>} maps developer-friendly flag names to
  #   whether the corresponding bits will be set in the flags field
  def initialize(new_flags)
    flags_number = 0
    new_flags.each do |name, value|
      mask = SpheroPwn::Commands::SetPermanentFlags::FLAGS[name]
      if mask.nil?
        raise ArgumentError, "Unknown flag #{name.inspect}"
      end
      flags_number |= mask if value
    end

    super 0x02, 0x35, [flags_number].pack('N').unpack('C*')
  end

  # @see {SpheroPwn::Command#response_class}
  def response_class
    SpheroPwn::Commands::SetPermanentFlags::Response
  end

  # @return {Hash<Symbol, Number>} numbers for the symbolic values
  FLAGS = SpheroPwn::Commands::GetPermanentFlags::FLAGS.invert.freeze
end

# The robot's configuration flags that persist across power cycles.
class SpheroPwn::Commands::SetPermanentFlags::Response < SpheroPwn::Response
end
