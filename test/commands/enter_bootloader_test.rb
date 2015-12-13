require_relative '../helper.rb'

describe SpheroPwn::Commands::EnterBootloader do
  it 'stringifies correctly' do
    set_device_mode = SpheroPwn::Commands::EnterBootloader.new
    sequence = 0x52

    assert_equal [0xFF, 0xFF, 0x00, 0x30, 0x52, 0x01, 0x7C],
                 set_device_mode.to_bytes(sequence).unpack('C*')
  end

  describe 'when sent to the robot' do
    before do
      @session = new_test_session :enter_bootloader
    end
    after do
      @session.send_command SpheroPwn::Commands::BootMainApp.new
      response = @session.recv_until_response
      unless response.code == :ok
        raise RuntimeError, 'Could not boot back into the main application'
      end

      @session.close
    end

    it 'gets an ok response' do
      @session.send_command SpheroPwn::Commands::EnterBootloader.new
      response = @session.recv_until_response
      assert_kind_of SpheroPwn::Commands::EnterBootloader::Response, response
      assert_equal :ok, response.code
    end
  end
end
