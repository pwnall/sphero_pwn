# The result of a get flash block request.
#
# This is an asynchronous message because it's too long to fit into the command
# response structure.
class SpheroPwn::Asyncs::FlashBlock < SpheroPwn::Async
  # @return {String} the text form of the diagnostics
  attr_reader :text

  def initialize(data_bytes)
    super
  end
end

class SpheroPwn::Asyncs::FlashBlock::Config < SpheroPwn::Asyncs::FlashBlock
  def self.id_code
    0x04
  end
end
SpheroPwn::Asyncs.register SpheroPwn::Asyncs::FlashBlock::Config

class SpheroPwn::Asyncs::FlashBlock::Soul < SpheroPwn::Asyncs::FlashBlock
  def self.id_code
    0x0D
  end
end
SpheroPwn::Asyncs.register SpheroPwn::Asyncs::FlashBlock::Soul
