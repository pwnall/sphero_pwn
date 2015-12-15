# Asks the robot to send a configuration block from the flash memory.
class SpheroPwn::Commands::GetFlashBlock < SpheroPwn::Command
  # @param {Symbol} block_type :soul, :factory_config or :user_config
  def initialize(block_type)
    case block_type
    when :soul
      command_id = 0x46
      data_bytes = nil
    when :factory_config
      command_id = 0x40
      data_bytes = [0x00]
    when :user_config
      command_id = 0x40
      data_bytes = [0x01]
    when /^block_/
      command_id = 0x40
      data_bytes = block_type.to_s.split('_')[1..-1].
                              map { |char| char.to_i(16) }
    else
      raise ArgumentError, "Unimplemented block type #{block_type.inspect}"
    end

    super 0x02, command_id, data_bytes
  end

  # @see {SpheroPwn::Command#response_class}
  def response_class
    SpheroPwn::Commands::GetFlashBlock::Response
  end
end

# The response to a get flash block command.
class SpheroPwn::Commands::GetFlashBlock::Response < SpheroPwn::Response
end
