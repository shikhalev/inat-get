# frozen_string_literal: true

require 'securerandom'

class UUID

  attr_reader :value

  def initialize value
    @value = value
  end

  class << self

    private :new

    def parse src
      return nil if src == nil
      raise TypeError, "Source must be a String!", caller unless String === src
      src = src.strip
      raise ArgumentError, "Invalid UUID source: #{ src.inspect }!", caller unless /^\h{8}\-\h{4}\-\h{4}\-\h{4}\-\h{12}$/ === src || /^\h{32}$/ === src
      value = src.gsub('-', '').to_i(16)
      new(value).freeze
    end

    def generate count = 1, prefix: nil, prefix_length: nil
      if prefix == nil
        if prefix_length != nil
          raise ArgumentError, "Prefix length must be Integer < 16!", caller unless Integer === prefix_length && prefix_length < 16
          prefix = SecureRandom.hex prefix_length
        else
          prefix = ''
          prefix_length = 0
        end
      else
        raise TypeError, "Prefix must be a String!", caller unless String === prefix
        prefix = prefix.gsub('-', '')
        prefix_length = prefix.length / 2
      end
      result = count.times.map { parse(prefix + SecureRandom.hex(16 - prefix_length)) }
      if count == 1
        result[0]
      else
        result
      end
    end

  end

  def to_s
    raw = @value.to_s(16)
    raw = '0' * (32 - raw.length) + raw if raw.length < 32
    "#{raw[0..7]}-#{raw[8..11]}-#{raw[12..15]}-#{raw[16..19]}-#{raw[20..31]}"
  end

  def inspect
    to_s
  end

  include Comparable

  def <=> other
    @value <=> other.value
  end

end
