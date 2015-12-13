# Asks the robot about the versions of its software stack components.
class SpheroPwn::Commands::GetVersions < SpheroPwn::Command
  def initialize
    super 0x00, 0x02, nil
  end

  # @see {SpheroPwn::Command#response_class}
  def response_class
    SpheroPwn::Commands::GetVersions::Response
  end
end

# The versions of a robot's software stack.
class SpheroPwn::Commands::GetVersions::Response < SpheroPwn::Response
  # @return {Hash<Symbol, Number>} the software versions of the components in
  #   the robot's software stack
  attr_reader :versions

  # @see {SpheroPwn::Response#initialize}
  def initialize(code_byte, sequence_byte, data_bytes)
    super

    @versions = {}
    if code == :ok
      response_version = data_bytes[0]
      if response_version >= 1
        @versions.merge!  model: data_bytes[1], hardware: data_bytes[2],
          sphero_app: { version: data_bytes[3], revision: data_bytes[4] },
          bootloader: self.class.parse_packed_nibble(data_bytes[5]),
          basic: self.class.parse_packed_nibble(data_bytes[6]),
          macros: self.class.parse_packed_nibble(data_bytes[7])
      end
      if response_version >= 2
        @versions.merge!  api: { major: data_bytes[8], minor: data_bytes[9] }
      end
    end
  end

  # Decodes a version from packed nibble format.
  #
  # @param {Number} byte the byte value packing the version
  # @return {Hash<Symbol, Number>} maps :major and :minor to version numbers
  def self.parse_packed_nibble(byte)
    { major: (byte >> 4), minor: (byte & 0x0F) }
  end
end
