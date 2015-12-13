require_relative '../helper.rb'

describe SpheroPwn::Commands::SetDeviceMode do
  it 'stringifies a normal mode request correctly' do
    set_device_mode = SpheroPwn::Commands::SetDeviceMode.new :normal
    sequence = 0x52

    assert_equal [0xFF, 0xFF, 0x02, 0x42, 0x52, 0x02, 0x00, 0x67],
                 set_device_mode.to_bytes(sequence).unpack('C*')
  end

  it 'stringifies a user hack mode request correctly' do
    set_device_mode = SpheroPwn::Commands::SetDeviceMode.new :user_hack
    sequence = 0x52

    assert_equal [0xFF, 0xFF, 0x02, 0x42, 0x52, 0x02, 0x01, 0x66],
                 set_device_mode.to_bytes(sequence).unpack('C*')
  end

  describe 'when sent to the robot' do
    before do
      @session = new_test_session :set_device_mode

      @session.send_command SpheroPwn::Commands::GetDeviceMode.new
      response = @session.recv_until_response
      unless response.code == :ok
        raise RuntimeError, 'Could not retrieve initial mode from device'
      end
      @old_mode = response.mode
    end
    after do
      @session.send_command SpheroPwn::Commands::SetDeviceMode.new(@old_mode)
      response = @session.recv_until_response
      unless response.code == :ok
        raise RuntimeError,
            "Could not restore initial device mode #{@old_mode}"
      end

      @session.close
    end

    it 'impacts the result of the get device mode command' do
      [:normal, :user_hack].each do |mode|
        @session.send_command SpheroPwn::Commands::SetDeviceMode.new(mode)
        response = @session.recv_until_response
        assert_kind_of SpheroPwn::Commands::SetDeviceMode::Response, response
        assert_equal :ok, response.code

        @session.send_command SpheroPwn::Commands::GetDeviceMode.new
        response = @session.recv_until_response
        assert_equal :ok, response.code
        assert_equal mode, response.mode
      end
    end
  end
end

