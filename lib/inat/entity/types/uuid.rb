# frozen_string_literal: true

class UUID

  include Comparable

  class << self

    def [] value                      # value is a string, a symbol or integer
      tmp = new value
      @values ||= {}
      @values[tmp.data] ||= tmp
      @values[tmp.data]
    end

    def generate
      # TODO: implement
    end

    private :new

    def make data, cache: nil, from: :API
      return nil if data.nil?
      self[data]
    end

    def db_type
      :TEXT
    end

  end

  attr_reader :data

  def initialize data
    if Symbol === data
      value = value.to_s
    end
    if String === data
      raise TypeError, "Invalid UUID string: #{data}!" unless /^\h{8}\-\h{4}\-\h{4}\-\h{4}\-\h{12}$/ === data || /^\h{32}$/ === data
      data = data.gsub('-', '').to_i(16)
    end
    raise TypeError, "Invalid UUID type: #{data.inspect}!" unless Integer === data
    @data = data
  end

  def to_s
    raw = @data.to_s(16)
    while raw.length < 32 do
      raw = '0' + raw
    end
    "#{raw[0..7]}-#{raw[8..11]}-#{raw[12..15]}-#{raw[16..19]}-#{raw[20..31]}"
  end

  def inspect
    to_s
  end

  def <=> other
    @data <=> other.data
  end

  def to_db
    to_s
  end

end
