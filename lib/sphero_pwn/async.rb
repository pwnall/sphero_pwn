# Superclass for all asynchronous messages sent from the robot to the computer.
class SpheroPwn::Async
  # @return {Array<Number>} the payload
  attr_reader :data_bytes


  def initialize(data_bytes)
    @data_bytes = data_bytes
  end
end
