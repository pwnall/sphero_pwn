require_relative '../helper.rb'

describe SpheroPwn::Commands::IsPageBlank do
  it 'stringifies correctly' do
    is_page_blank = SpheroPwn::Commands::IsPageBlank.new 0x67
    sequence = 0x52

    assert_equal [0xFF, 0xFF, 0x01, 0x05, 0x52, 0x02, 0x67, 0x3E],
                 is_page_blank.to_bytes(sequence).unpack('C*')
  end

  it 'parses a yes response correctly' do
    response = SpheroPwn::Commands::IsPageBlank::Response.new 0x00, 0x00,
        [0x01]

    assert_equal :ok, response.code
    assert_equal true, response.is_blank
    assert_equal true, response.is_blank?
  end

  it 'parses a no response correctly' do
    response = SpheroPwn::Commands::IsPageBlank::Response.new 0x00, 0x00,
        [0x00]

    assert_equal :ok, response.code
    assert_equal false, response.is_blank
    assert_equal false, response.is_blank?
  end

  it 'does not crash when parsing an error response' do
    response = SpheroPwn::Commands::IsPageBlank::Response.new 0x32, 0x00,
        [0x01]

    assert_equal :bad_page, response.code
    assert_equal nil, response.is_blank
    assert_equal nil, response.is_blank?
  end

  describe 'when sent to the robot' do
    before do
      @session = new_test_session :is_page_blank
      @session.send_command SpheroPwn::Commands::EnterBootloader.new
      response = @session.recv_until_response
      unless response.code == :ok
        raise RuntimeError, 'Could not jump into bootloader'
      end
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
      @session.send_command SpheroPwn::Commands::IsPageBlank.new(16)
      response = @session.recv_until_response
      assert_kind_of SpheroPwn::Commands::IsPageBlank::Response, response
      assert_equal :ok, response.code
    end
  end
end
