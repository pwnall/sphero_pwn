require_relative '../helper.rb'

describe SpheroPwn::Commands::SetPermanentFlags do
  it 'stringifies correctly' do
    set_flags = SpheroPwn::Commands::SetPermanentFlags.new(
        no_sleep_while_charging: false, vector_drive: true,
        tail_led_always_on: true, motion_timeouts: true,
        light_double_tap: true, heavy_double_tap: false,
        gyro_max_async: true)
    sequence = 0x52

    assert_equal [0xFF, 0xFF, 0x02, 0x35, 0x52, 0x05, 0x00, 0x00, 0x01, 0x5A,
        0x16], set_flags.to_bytes(sequence).unpack('C*')
  end

  describe 'when sent to the robot' do
    before do
      @session = new_test_session :set_permanent_flags
      @session.send_command SpheroPwn::Commands::GetPermanentFlags.new
      response = @session.recv_until_response
      unless response.code == :ok
        raise RuntimeError, 'Could not get original permanent flags'
      end
      @old_flags = response.flags
    end
    after do
      @session.send_command(
          SpheroPwn::Commands::SetPermanentFlags.new(@old_flags))
      response = @session.recv_until_response
      unless response.code == :ok
        raise RuntimeError, 'Could not restore original permanent flags'
      end

      @session.close
    end

    it 'changes the result of the get permanent flags command' do
      new_flags = @old_flags.dup
      new_flags[:vector_drive] = !new_flags[:vector_drive]

      @session.send_command(
          SpheroPwn::Commands::SetPermanentFlags.new(new_flags))
      response = @session.recv_until_response
      assert_kind_of SpheroPwn::Commands::SetPermanentFlags::Response,
                     response
      assert_equal :ok, response.code

      @session.send_command SpheroPwn::Commands::GetPermanentFlags.new
      response = @session.recv_until_response
      assert_equal :ok, response.code
      assert_equal new_flags, response.flags
      refute_equal @old_flags, response.flags
    end
  end
end
