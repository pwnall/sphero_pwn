require 'rubyserial'
require 'thread'

# Communication channel with a robot.
#
# This is a light abstraction over the Bluetooth serial port (RFCONN) used to
# talk to a robot.
class SpheroPwn::Channel
  # Opens up a communication channel with a robot.
  #
  # @param {String} rfconn_path the path to the device file connecting to the
  #   robot's Bluetooth RFCONN service
  # @param {Number} timeout the number of seconds to retry connecting when
  #   getting EBUSY
  def initialize(rfconn_path, timeout = 15)
    give_up_at = Time.now + timeout
    @port = nil
    while @port.nil?
      begin
        @port = Serial.new rfconn_path, 115200
      rescue RubySerial::Exception => e
        raise e unless e.message == 'EBUSY'
        raise e if Time.now >= give_up_at
      end
    end

    @send_queue = Queue.new
    @send_thread = Thread.new @send_queue do
      send_queue = @send_queue

      loop do
        bytes = send_queue.pop
        break if bytes == :close

        @port.write bytes
      end
    end
  end

  # @param {String} bytes a binary-encoded string of bytes to be sent to the
  #   robot over the RFCONN port
  # @return {Channel} self
  def send_bytes(bytes)
    @send_queue.push bytes
    self
  end

  # @param {Integer} count the number of bytes to be read from the RFCONN port
  def recv_bytes(count)
    retries_left = 100_000
    while retries_left > 0
      bytes = @port.read count
      return bytes unless bytes.empty?
      retries_left -= 1
    end
    nil
  end

  # Gracefully shuts down the communication channel with the robot.
  #
  # @return {Channel} self
  def close
    @send_queue.push :close
    @port.close
    self
  end
end
