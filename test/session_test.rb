require_relative './helper.rb'

describe SpheroPwn::Session do
  describe '#valid_checksum?' do
    it 'works on a correct example without data' do
      assert_equal true, SpheroPwn::Session.valid_checksum?([0x00, 0x01, 0x01],
          [], 0xfd)
    end

    it 'fails an incorrect example without data' do
      assert_equal false, SpheroPwn::Session.valid_checksum?(
          [0x00, 0x01, 0x01], [], 0xfa)
    end
  end
end
