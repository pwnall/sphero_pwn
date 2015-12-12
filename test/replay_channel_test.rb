require_relative './helper.rb'

require 'stringio'

describe SpheroPwn::ReplayChannel do
  describe 'with one send operation' do
    let :replay do
      input = StringIO.new "> 48 65 6c 6c 6f 0a\n"
      File.stub :open, input do
        SpheroPwn::ReplayChannel.new '/tmp/stubbed'
      end
    end

    it 'returns self when data is sent correctly' do
      assert_equal replay, replay.send_bytes("Hello\n")
      assert_equal replay, replay.close
    end

    it 'compares sent data against recording' do
      exception = assert_raises ArgumentError do
        replay.send_bytes "Hwlo"
      end

      golden_error = 'Incorrect bytes sent! ' +
        'Expected: [72, 101, 108, 108, 111, 10] Got: [72, 119, 108, 111]'
      assert_equal golden_error, exception.message
    end

    it 'complains if closed early' do
      exception = assert_raises RuntimeError do
        replay.close
      end
      assert_equal 'Closed before performing 1 operations!', exception.message
    end

    it 'complains if attempting to receive' do
      exception = assert_raises RuntimeError do
        replay.recv_bytes 1
      end
      assert_equal 'Received data at an unexpected time!', exception.message
    end
  end

  describe 'with one receive operation' do
    let :replay do
      input = StringIO.new "< 48 65 6c 6c 6f 20 74 6f 6f 21 0a\n"
      File.stub :open, input do
        SpheroPwn::ReplayChannel.new '/tmp/stubbed'
      end
    end

    it 'receives correctly in one shot' do
      assert_equal "Hello too!\n", replay.recv_bytes(11)
      assert_equal replay, replay.close
    end

    it 'receives correctly in two shots' do
      assert_equal 'Hello', replay.recv_bytes(5)
      assert_equal " too!\n", replay.recv_bytes(6)
      assert_equal replay, replay.close
    end

    it 'receives correctly in three shots' do
      assert_equal 'Hello', replay.recv_bytes(5)
      assert_equal ' ', replay.recv_bytes(1)
      assert_equal "too!\n", replay.recv_bytes(5)
      assert_equal replay, replay.close
    end

    it 'complains if closed early' do
      exception = assert_raises RuntimeError do
        replay.close
      end
      assert_equal 'Closed before performing 1 operations!', exception.message
    end

    it 'complains if attempting to send before receiving anything' do
      exception = assert_raises RuntimeError do
        replay.send_bytes "Hello"
      end
      assert_equal 'Sent data before receiving 11 of 11 bytes!',
                   exception.message
    end

    it 'complains if attempting to send before receiving everything' do
      assert_equal 'Hello', replay.recv_bytes(5)
      exception = assert_raises RuntimeError do
        replay.send_bytes "Hello"
      end
      assert_equal 'Sent data before receiving 6 of 11 bytes!',
                   exception.message
    end
  end

  describe 'with no operation' do
    let :replay do
      input = StringIO.new ''
      File.stub :open, input do
        SpheroPwn::ReplayChannel.new '/tmp/stubbed'
      end
    end

    it 'closes correctly' do
      assert_equal replay, replay.close
    end

    it 'complaints if attempting to send' do
      exception = assert_raises RuntimeError do
        replay.send_bytes "Hello\n"
      end
      assert_equal 'Sent data at an unexpected time!', exception.message
    end

    it 'complains if attempting to receive' do
      exception = assert_raises RuntimeError do
        replay.recv_bytes 1
      end
      assert_equal 'Received data at an unexpected time!', exception.message
    end
  end

  describe 'with a sequence of operations' do
    let :replay do
      input = StringIO.new <<END_STRING
> 48 65 6c 6c 6f 0a
< 48 65 6c 6c 6f 20 74 6f 6f 21 0a
> 4f 4b
> 42 79 65 0a
< 42 79 65 20 62 79 65 0a
END_STRING
      File.stub :open, input do
        SpheroPwn::ReplayChannel.new '/tmp/stubbed'
      end
    end

    it 'replays the operations correctly' do
      assert_equal replay, replay.send_bytes("Hello\n")
      assert_equal 'Hello', replay.recv_bytes(5)
      assert_equal " too!\n", replay.recv_bytes(6)
      assert_equal replay, replay.send_bytes('OK')
      assert_equal replay, replay.send_bytes("Bye\n")
      assert_equal 'Bye', replay.recv_bytes(3)
      assert_equal " bye\n", replay.recv_bytes(5)
      assert_equal replay, replay.close
    end
  end
end
