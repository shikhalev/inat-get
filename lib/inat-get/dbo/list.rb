
require_relative './mod'

class ING::DBO::List

  attr_reader :type

  def initialize type
    @type = type
  end

  def to_s
    "List[#{ @type }]"
  end

  def inspect
    to_s
  end

  class << self

    private :new

    def [] type
      @types ||= {}
      @types[type] ||= new type
      @types[type]
    end

  end

end
