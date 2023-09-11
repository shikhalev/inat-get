
require_relative 'model'

class INat::Model::Unique < INat::Model

  field :id, type: Integer

  class << self

    def [] id
      @objects ||= {}
      @objects[id]
    end

    def from hash
      if hash != nil
        id = hash[:id] || hash['id']
        raise ArgumentError::new ":id not found or null" if !id
        @objects ||= {}
        obj = @objects[id] || self.new
        obj.send :from!, hash
        @objects[id] = obj
        obj
      else
        nil
      end
    end

  end

end
