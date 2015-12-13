# Asks the robot to send ASCII diagnostic data.
class SpheroPwn::Commands::L2Diagnostics < SpheroPwn::Command
  def initialize
    super 0x00, 0x41, nil
  end

  # @see {SpheroPwn::Command#response_class}
  def response_class
    SpheroPwn::Commands::L2Diagnostics::Response
  end
end

# The response to an L2 diagnostics command.
class SpheroPwn::Commands::L2Diagnostics::Response < SpheroPwn::Response
  # @return {Hash<Symbol, Number>} debugging information counters
  attr_reader :counters

  # @see {SpheroPwn::Response#initialize}
  def initialize(code_byte, sequence_byte, data_bytes)
    super

    @counters = {}
    if code == :ok
      data_string = data_bytes.pack('C*')
      response_version = data_bytes[0x02]
      if response_version >= 1
        @counters.merge! received_good: data_string[0x03, 4].unpack('N'),
          reserved1: data_bytes[0x02],
          bad_device_id: data_string[0x07, 4].unpack('N'),
          bad_data_length: data_string[0x0B, 4].unpack('N'),
          bad_command_id: data_string[0x0F, 4].unpack('N'),
          bad_checksum: data_string[0x13, 4].unpack('N'),
          rx_buffer_overrun: data_string[0x17, 4].unpack('N'),
          transmitted: data_string[0x1B, 4].unpack('N'),
          tx_buffer_overrun: data_string[0x1F, 4].unpack('N'),
          last_boot_reason: data_bytes[0x23],
          boots_by_reason: data_string[0x24, 32].unpack('n*'),
          reserved2: data_string[0x44, 2].unpack('n'),
          charge_count: data_string[0x46, 2].unpack('n'),
          seconds_since_charge: data_string[0x48, 2].unpack('n'),
          seconds_on: data_string[0x4A, 4].unpack('N'),
          distance_rolled: data_string[0x4E, 4].unpack('N'),
          i2c_failures: data_string[0x52, 2].unpack('n'),
          gyro_adjusts: data_string[0x54, 4].unpack('N')
      end
    end
  end
end
