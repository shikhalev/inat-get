
require_relative 'model'

module INat::Model::Mergeable

  def x_merge! other
    other.each_field do |field, value|
      self.send "#{field}=", value
    end
    self
  end

end
