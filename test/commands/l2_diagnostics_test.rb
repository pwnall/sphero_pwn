require_relative '../helper.rb'

describe SpheroPwn::Commands::L2Diagnostics do
  it 'parses a v1 response record correctly' do
    # TODO(pwnall): Find a device tht implements this command.
  end

  it 'does not crash when receiving an error' do
    response = SpheroPwn::Commands::L2Diagnostics::Response.new 0x05, 0x00, []

    assert_equal :unsupported, response.code
    refute_nil response.counters
  end

  describe 'when sent to the robot' do
    before do
      @session = new_test_session :l2_diagnostics

      @session.send_command SpheroPwn::Commands::GetDeviceMode.new
      response = @session.recv_until_response
      unless response.code == :ok
        raise RuntimeError, 'Could not retrieve initial mode from device'
      end
      @old_mode = response.mode

      @session.send_command SpheroPwn::Commands::SetDeviceMode.new :user_hack
      response = @session.recv_until_response
      unless response.code == :ok
        raise RuntimeError, 'Could not set user hack mode'
      end
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

    it 'receives a response with counters' do
      @session.send_command SpheroPwn::Commands::L2Diagnostics.new
      response = @session.recv_until_response
      assert_kind_of SpheroPwn::Commands::L2Diagnostics::Response, response

      # TODO(pwnall): Find a device that implements this command so we can
      #               test it.
      # assert_equal :ok, response.code
      # assert_operator response.counters[:received_good], :>, 0
      # assert_operator response.counters[:seconds_on], :>, 0
      # refute_nil response.counters[:i2c_failures]
      # refute_nil response.counters[:gyro_adjusts]
    end
  end
end

