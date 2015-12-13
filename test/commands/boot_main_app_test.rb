require_relative '../helper.rb'

describe SpheroPwn::Commands::BootMainApp do
  it 'stringifies correctly' do
    set_device_mode = SpheroPwn::Commands::BootMainApp.new
    sequence = 0x52

    assert_equal [0xFF, 0xFF, 0x01, 0x04, 0x52, 0x01, 0xA7],
                 set_device_mode.to_bytes(sequence).unpack('C*')
  end
end
