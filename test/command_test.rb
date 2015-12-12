require_relative './helper.rb'

describe SpheroPwn::Command do
  it 'stringifies the ping example correctly' do
    ping = SpheroPwn::Command.new 0x00, 0x01, nil
    sequence = 0x52

    bytes = ping.to_bytes sequence
    assert_equal [0xFF, 0xFF, 0x00, 0x01, 0x52, 0x01, 0xAB], bytes.unpack('C*')
    assert_equal Encoding::BINARY, bytes.encoding
  end

  it 'stringifies a command with data correctly' do
    set_device_mode = SpheroPwn::Command.new 0x02, 0x42, [0x00]
    sequence = 0x52

    bytes = set_device_mode.to_bytes sequence
    assert_equal [0xFF, 0xFF, 0x02, 0x42, 0x52, 0x02, 0x00, 0x67],
                 bytes.unpack('C*')
    assert_equal Encoding::BINARY, bytes.encoding
  end

  it 'clears the response bit correctly' do
    ping = SpheroPwn::Command.new 0x00, 0x01, nil
    assert_equal true, ping.expects_response?

    ping.no_response!
    assert_equal false, ping.expects_response?
    sequence = 0x52

    bytes = ping.to_bytes sequence
    assert_equal [0xFF, 0xFE, 0x00, 0x01, 0x52, 0x01, 0xAB], bytes.unpack('C*')
    assert_equal Encoding::BINARY, bytes.encoding
  end

  it 'clears the timeout bit correctly' do
    ping = SpheroPwn::Command.new 0x00, 0x01, nil
    ping.no_timeout_reset!
    sequence = 0x52

    bytes = ping.to_bytes sequence
    assert_equal [0xFF, 0xFD, 0x00, 0x01, 0x52, 0x01, 0xAB], bytes.unpack('C*')
    assert_equal Encoding::BINARY, bytes.encoding
  end
end
