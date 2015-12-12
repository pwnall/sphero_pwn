# Implements the Channel API using data from a file.
class SpheroPwn::ReplayChannel
  #
  #
  # @param {String} recording_path the file storing the recording
  def initialize(recording_path)
    @file = File.open recording_path, 'rt'
    @lines = @file.read.split("\n").map do |line|
      tokens = line.split ' '

      tokens.map! do |token|
        case token
        when '<'
          :recv
        when '>'
          :send
        else
          token.to_i 16
        end
      end
    end

    @line_index = 0
    @byte_index = 0
  end

  # @see {Channel#recv_bytes}
  def recv_bytes(count)
    if @lines[@line_index].nil? || @lines[@line_index].first != :recv
      raise RuntimeError, "Received data at an unexpected time!"
    end

    line_bytes = @lines[@line_index].length - 1
    if @byte_index + count > line_bytes
      raise ArgumentError, "Attempted to receive #{count} bytes, but only " +
          "#{line_bytes - @byte_index} are available"
    end

    data = @lines[@line_index][@byte_index + 1, count].pack('C*')
    @byte_index += count

    if @byte_index == line_bytes
      @byte_index = 0
      @line_index += 1
    end

    data
  end

  # @see {Channel#send_bytes}
  def send_bytes(bytes)
    if @lines[@line_index] && @lines[@line_index].first == :recv
      line_bytes = @lines[@line_index].length - 1
      raise RuntimeError, "Sent data before receiving " +
          "#{line_bytes - @byte_index} of #{line_bytes} bytes!"
    end

    if @lines[@line_index].nil? || @lines[@line_index].first != :send
      raise RuntimeError, "Sent data at an unexpected time!"
    end

    expected = @lines[@line_index][1..-1]
    data = bytes.unpack 'C*'
    if data != expected
      raise ArgumentError, "Incorrect bytes sent! " +
          "Expected: #{expected.inspect} Got: #{data.inspect}"
    end
    @line_index += 1
    self
  end

  # @see {Channel#close}
  def close
    if @line_index != @lines.length
      ops_left = @lines.length - @line_index
      raise RuntimeError, "Closed before performing #{ops_left} operations!"
    end

    self
  end
end
