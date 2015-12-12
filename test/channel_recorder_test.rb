require_relative './helper.rb'

require 'stringio'

describe SpheroPwn::ChannelRecorder do
  describe 'with a channel that always responds' do
    before do
      @channel = MiniTest::Mock.new
      @channel.expect :send_bytes, @channel, ["Hello\n"]
      @channel.expect :recv_bytes, 'Hello', [5]
      @channel.expect :recv_bytes, " too!\n", [6]
      @channel.expect :send_bytes, @channel, ['OK']
      @channel.expect :send_bytes, @channel, ["Bye\n"]
      @channel.expect :recv_bytes, 'Bye', [3]
      @channel.expect :recv_bytes, " bye\n", [5]
      @channel.expect :close, @channel, []
    end

    after { @channel.verify }

    it 'proxies calls correctly' do
      output = StringIO.new
      recorder = File.stub :open, output do
        SpheroPwn::ChannelRecorder.new @channel, '/tmp/stubbed'
      end

      assert_equal recorder, recorder.send_bytes("Hello\n")
      assert_equal 'Hello', recorder.recv_bytes(5)
      assert_equal " too!\n", recorder.recv_bytes(6)
      assert_equal recorder, recorder.send_bytes('OK')
      assert_equal recorder, recorder.send_bytes("Bye\n")
      assert_equal 'Bye', recorder.recv_bytes(3)
      assert_equal " bye\n", recorder.recv_bytes(5)
      assert_equal recorder, recorder.close
    end

    it 'produces the output file correctly' do
      output = StringIO.new
      recorder = File.stub :open, output do
        SpheroPwn::ChannelRecorder.new @channel, '/tmp/stubbed'
      end

      recorder.send_bytes "Hello\n"
      recorder.recv_bytes 5
      recorder.recv_bytes 6
      recorder.send_bytes 'OK'
      recorder.send_bytes "Bye\n"
      recorder.recv_bytes 3
      recorder.recv_bytes 5
      recorder.close

      golden = <<END_STRING
> 48 65 6C 6C 6F 0A
< 48 65 6C 6C 6F 20 74 6F 6F 21 0A
> 4F 4B
> 42 79 65 0A
< 42 79 65 20 62 79 65 0A
END_STRING
      assert_equal golden, output.string
    end
  end

  describe 'with a channel that sometimes returns nils' do
    before do
      @channel = MiniTest::Mock.new
      @channel.expect :send_bytes, @channel, ["Hello\n"]
      @channel.expect :recv_bytes, nil, [5]
      @channel.expect :recv_bytes, "Hello too!\n", [11]
      @channel.expect :close, @channel, []
    end

    it 'proxies calls correctly' do
      output = StringIO.new
      recorder = File.stub :open, output do
        SpheroPwn::ChannelRecorder.new @channel, '/tmp/stubbed'
      end

      assert_equal recorder, recorder.send_bytes("Hello\n")
      assert_equal nil, recorder.recv_bytes(5)
      assert_equal "Hello too!\n", recorder.recv_bytes(11)
      assert_equal recorder, recorder.close
    end

    it 'produces the output file correctly' do
      output = StringIO.new
      recorder = File.stub :open, output do
        SpheroPwn::ChannelRecorder.new @channel, '/tmp/stubbed'
      end

      recorder.send_bytes "Hello\n"
      recorder.recv_bytes 5
      recorder.recv_bytes 11
      recorder.close

      golden = <<END_STRING
> 48 65 6C 6C 6F 0A
< 48 65 6C 6C 6F 20 74 6F 6F 21 0A
END_STRING
      assert_equal golden, output.string
    end
  end
end
