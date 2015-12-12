# Records all the bytes going to a channel.
class SpheroPwn::ChannelRecorder
  # @param {Channel} the channel being recorded
  # @param {String} recording_path the file where the recording will be saved
  def initialize(channel, recording_path)
    @channel = channel
    @file = File.open recording_path, 'wt'

    @is_receiving = false
  end

  # @see {Channel#recv_bytes}
  def recv_bytes(count)
    bytes = @channel.recv_bytes count
    return bytes if bytes.nil?

    unless @is_receiving
      @file.write '<'
      @is_receiving = true
    end
    log_bytes bytes
    @file.flush

    bytes
  end

  # @see {Channel#send_bytes}
  def send_bytes(bytes)
    if @is_receiving
      @file.write "\n"
      @is_receiving = false
    end

    @file.write '>'
    log_bytes bytes
    @file.write "\n"
    @file.flush

    @channel.send_bytes bytes
    self
  end

  # @see {Channel#close}
  def close
    if @is_receiving
      @file.write "\n"
    end
    @file.close
    @channel.close
    self
  end

  # @param {String} bytes the bytes to be written to the output file
  def log_bytes(bytes)
    unless bytes.empty?
      @file.write bytes.unpack('C*').map { |byte| ' %02X' % byte }.join('')
    end
  end
  private :log_bytes
end
