require_relative './helper.rb'

describe SpheroPwn::Response do
  it 'saves constructor args correctly' do
    response = SpheroPwn::Response.new 0x00, 0x52, [0xAA, 0xBB]
    assert_equal :ok, response.code
    assert_equal 0x52, response.sequence
    assert_equal [0xAA, 0xBB], response.data_bytes
  end

  it 'handles unknown response codes correctly' do
    response = SpheroPwn::Response.new 0xFA, 0x52, [0xAA, 0xBB]
    assert_equal :unknown, response.code
  end
end
