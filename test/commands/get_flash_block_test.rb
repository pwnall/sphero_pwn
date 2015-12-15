require_relative '../helper.rb'

describe SpheroPwn::Commands::GetFlashBlock do
  it 'stringifies get soul correctly' do
    get_block = SpheroPwn::Commands::GetFlashBlock.new :soul
    sequence = 0x52

    bytes = get_block.to_bytes sequence
    assert_equal [0xFF, 0xFF, 0x02, 0x46, 0x52, 0x01, 0x64], bytes.unpack('C*')
    assert_equal Encoding::BINARY, bytes.encoding
  end

  it 'stringifies get factory config correctly' do
    get_block = SpheroPwn::Commands::GetFlashBlock.new :factory_config
    sequence = 0x52

    bytes = get_block.to_bytes sequence
    assert_equal [0xFF, 0xFF, 0x02, 0x40, 0x52, 0x02, 0x00, 0x69],
                 bytes.unpack('C*')
    assert_equal Encoding::BINARY, bytes.encoding
  end

  it 'stringifies get user config correctly' do
    get_block = SpheroPwn::Commands::GetFlashBlock.new :user_config
    sequence = 0x52

    bytes = get_block.to_bytes sequence
    assert_equal [0xFF, 0xFF, 0x02, 0x40, 0x52, 0x02, 0x01, 0x68],
                 bytes.unpack('C*')
    assert_equal Encoding::BINARY, bytes.encoding
  end

  it 'stringifies a custom block number correctly' do
    get_block = SpheroPwn::Commands::GetFlashBlock.new :block_01_42_ff
    sequence = 0x52

    bytes = get_block.to_bytes sequence
    assert_equal [0xFF, 0xFF, 0x02, 0x40, 0x52, 0x04, 0x01, 0x42, 0xff, 0x25],
                 bytes.unpack('C*')
    assert_equal Encoding::BINARY, bytes.encoding
  end

  describe 'when get soul is sent to the robot' do
    before { @session = new_test_session :get_soul }
    after { @session.close }

    it 'receives a response and an async result' do
      @session.send_command SpheroPwn::Commands::GetFlashBlock.new :soul

      response = nil
      async = nil
      while response.nil? || async.nil?
        message = @session.recv_message
        if message.nil?
          sleep 0.05
          next
        end

        if message.kind_of? SpheroPwn::Response
          response = message
          assert_kind_of SpheroPwn::Commands::GetFlashBlock::Response, response
          assert_equal :ok, response.code
        else
          async = message
          assert_kind_of SpheroPwn::Asyncs::FlashBlock::Soul, async
          assert_equal 0x400, async.data_bytes.length
        end
      end
    end
  end

  describe 'when get factory config is sent to the robot' do
    before { @session = new_test_session :get_factory_config }
    after { @session.close }

    it 'receives a response and an async result' do
      @session.send_command(
          SpheroPwn::Commands::GetFlashBlock.new(:factory_config))

      response = nil
      async = nil
      while response.nil? || async.nil?
        message = @session.recv_message
        if message.nil?
          sleep 0.05
          next
        end

        if message.kind_of? SpheroPwn::Response
          response = message
          assert_kind_of SpheroPwn::Commands::GetFlashBlock::Response, response
          assert_equal :ok, response.code
        else
          async = message
          assert_kind_of SpheroPwn::Asyncs::FlashBlock::Config, async
          assert_equal 0x400, async.data_bytes.length
        end
      end
    end
  end
end
