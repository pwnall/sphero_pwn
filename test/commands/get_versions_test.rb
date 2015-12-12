require_relative '../helper.rb'

describe SpheroPwn::Commands::GetVersions do
  it 'parses a v1 response record correctly' do
    response = SpheroPwn::Commands::GetVersions::Response.new 0x01, 0x00,
        [0x02, 0x03, 0x01, 0xaa, 0xbb, 0x51, 0x67, 0x89]

    assert_equal 3, response.versions[:model]
    assert_equal 1, response.versions[:hardware]
    assert_equal({ version: 0xaa, revision: 0xbb },
                 response.versions[:sphero_app])
    assert_equal({ major: 5, minor: 1}, response.versions[:bootloader])
    assert_equal({ major: 6, minor: 7}, response.versions[:basic])
    assert_equal({ major: 8, minor: 9}, response.versions[:macros])
  end

  describe 'when sent to the robot' do
    before { @session = new_test_session :get_version }
    after { @session.close }

    it 'receives a response with version numbers' do
      @session.send_command SpheroPwn::Commands::GetVersions.new
      response = @session.recv_until_response
      assert_kind_of SpheroPwn::Commands::GetVersions::Response, response

      assert_equal :ok, response.code
      refute_nil response.versions[:model]
      refute_nil response.versions[:hardware]
      refute_nil response.versions[:bootloader]
      refute_nil response.versions[:basic]
      refute_nil response.versions[:macros]
    end
  end
end
