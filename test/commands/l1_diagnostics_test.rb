require_relative '../helper.rb'

describe SpheroPwn::Commands::L1Diagnostics do
  it 'parses an async response correctly' do
    async = SpheroPwn::Asyncs.create 0x02, [0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x0A]

    assert_kind_of SpheroPwn::Asyncs::L1Diagnostics, async
    assert_equal "Hello\n", async.text
  end

  describe 'when sent to the robot' do
    before { @session = new_test_session :l1_diagnostics }
    after { @session.close }

    it 'receives a response and an async result' do
      @session.send_command SpheroPwn::Commands::L1Diagnostics.new

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
          assert_kind_of SpheroPwn::Commands::L1Diagnostics::Response, response
          assert_equal :ok, response.code
        else
          async = message
          assert_kind_of SpheroPwn::Asyncs::L1Diagnostics, async
          assert_operator async.text.length, :>=, 200
        end
      end
    end
  end
end

