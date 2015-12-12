# Namespace for asynchronous messages sent from the robot to the computer.
module SpheroPwn::Asyncs
  # Called by SpheroPwn::Async subclasses to register themselves.
  #
  # @param {Class<SpheroPwn::Async>} klass a class that parses asynchronous
  #   messages with an ID code
  def self.register(klass)
    id_code = klass.id_code
    if other_klass = CLASSES[id_code]
      raise ArgumentError,
          "Async ID code #{id_code} already registered by #{other_klass}"
    end
    CLASSES[id_code] = klass
  end

  # Subclasses override this and return the ID of the commands they can parse.
  #
  # @return {Number} the ID byte value identifying the commands that can be
  #   parsed by this class
  def self.id_code
    raise RuntimeError, 'id_code must be implemented by subclasses'
  end

  # @param {Number} class_id the asynchronous message's ID code
  # @return {Class<SpheroPwn::Async>} the class that can parse
  def self.create(class_id, data_bytes)
    return nil unless klass = CLASSES[class_id]
    klass.new data_bytes
  end


  # Maps ID codes to classes handling responses.
  CLASSES = {}
end
