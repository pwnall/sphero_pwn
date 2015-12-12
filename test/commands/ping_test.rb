require_relative '../helper.rb'

describe SpheroPwn::Commands::Ping do
  it 'stringifies the ping example correctly' do
    ping = SpheroPwn::Commands::Ping.new
    sequence = 0x52

    bytes = ping.to_bytes sequence
    assert_equal [0xFF, 0xFF, 0x00, 0x01, 0x52, 0x01, 0xAB], bytes.unpack('C*')
    assert_equal Encoding::BINARY, bytes.encoding
  end

  describe 'when sent to the robot' do
    before { @session = new_test_session :ping }
    after { @session.close }

    it 'receives a response' do
      @session.send_command SpheroPwn::Commands::Ping.new
      response = @session.recv_until_response

      assert_kind_of SpheroPwn::Commands::Ping::Response, response
      assert_equal :ok, response.code
    end
  end
end
