require_relative '../helper.rb'

describe SpheroPwn::Commands::GetPermanentFlags do
  it 'parses a response correctly' do
    response = SpheroPwn::Commands::GetPermanentFlags::Response.new 0x00, 0x00,
        [0x00, 0x00, 0x01, 0x5A]

    assert_equal :ok, response.code
    assert_equal false, response.flags[:no_sleep_while_charging]
    assert_equal true, response.flags[:vector_drive]
    assert_equal false, response.flags[:no_leveling_while_charging]
    assert_equal true, response.flags[:tail_led_always_on]
    assert_equal true, response.flags[:motion_timeouts]
    assert_equal false, response.flags[:demo_mode]
    assert_equal true, response.flags[:light_double_tap]
    assert_equal false, response.flags[:heavy_double_tap]
    assert_equal true, response.flags[:gyro_max_async]
  end

  it 'does not crash when parsing an error response' do
    response = SpheroPwn::Commands::GetPermanentFlags::Response.new 0x05, 0x00,
        []

    assert_equal :unsupported, response.code
    assert_equal nil, response.flags[:no_sleep_while_charging]
    assert_equal nil, response.flags[:vector_drive]
    assert_equal nil, response.flags[:no_leveling_while_charging]
    assert_equal nil, response.flags[:tail_led_always_on]
    assert_equal nil, response.flags[:motion_timeouts]
    assert_equal nil, response.flags[:demo_mode]
    assert_equal nil, response.flags[:light_double_tap]
    assert_equal nil, response.flags[:heavy_double_tap]
    assert_equal nil, response.flags[:gyro_max_async]
  end

  describe 'when sent to the robot' do
    before { @session = new_test_session :get_permanent_flags }
    after { @session.close }

    it 'gets an ok response' do
      @session.send_command SpheroPwn::Commands::GetPermanentFlags.new
      response = @session.recv_until_response
      assert_kind_of SpheroPwn::Commands::GetPermanentFlags::Response, response
      assert_equal :ok, response.code
    end
  end
end

