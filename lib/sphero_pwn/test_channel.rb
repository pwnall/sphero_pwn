module SpheroPwn
  # Intelligently toggles between recording and replaying test data.
  #
  # @param {String} rfconn_path the path to the device file connecting to the
  #   robot's Bluetooth RFCONN service
  # @param {String} recording_path the file storing the recording
  # @return {Channel} if the recording file at the given path exists, the
  #   return value is a {ReplayChannel} that uses the file; otherwise, the
  #   return value is a {ChannelRecorder} that creates the recording
  def self.new_test_channel(rfconn_path, recording_path)
    if File.exist? recording_path
      ReplayChannel.new recording_path
    else
      channel = Channel.new rfconn_path
      ChannelRecorder.new channel, recording_path
    end
  end
end
