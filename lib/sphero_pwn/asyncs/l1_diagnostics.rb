# The result of an L1 diagnostic request.
#
# This is an asynchronous message because it's too long to fit into the command
# response structure.
class SpheroPwn::Asyncs::L1Diagnostics < SpheroPwn::Async
  # @return {String} the text form of the diagnostics
  attr_reader :text

  def initialize(data_bytes)
    super

    @text = data_bytes.pack('C*').encode! Encoding::UTF_8
  end


  def self.id_code
    0x02
  end
end

SpheroPwn::Asyncs.register SpheroPwn::Asyncs::L1Diagnostics
