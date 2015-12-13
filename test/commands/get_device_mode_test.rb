require_relative '../helper.rb'

describe SpheroPwn::Commands::GetDeviceMode do
  it 'parses a normal mode response correctly' do
    response = SpheroPwn::Commands::GetDeviceMode::Response.new 0x00, 0x00,
        [0x00]

    assert_equal :ok, response.code
    assert_equal :normal, response.mode
  end

  it 'parses a user hack mode response correctly' do
    response = SpheroPwn::Commands::GetDeviceMode::Response.new 0x00, 0x00,
        [0x01]

    assert_equal :ok, response.code
    assert_equal :user_hack, response.mode
  end

  it 'does not crash when parsing an error response' do
    response = SpheroPwn::Commands::GetDeviceMode::Response.new 0x05, 0x00,
        [0x00]

    assert_equal :unsupported, response.code
    assert_equal :error, response.mode
  end

  describe 'when sent to the robot' do
    before { @session = new_test_session :get_device_mode }
    after { @session.close }

    it 'receives a response' do
      @session.send_command SpheroPwn::Commands::GetDeviceMode.new
      response = @session.recv_until_response
      assert_kind_of SpheroPwn::Commands::GetDeviceMode::Response, response

      assert_equal :ok, response.code
    end
  end
end
