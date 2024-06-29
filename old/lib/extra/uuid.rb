# frozen_string_literal: true

require 'securerandom'

class UUID

  BASE   = 16
  BYTES  = 16
  DIGITS = 32

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
      value = src.gsub('-', '').to_i(BASE)
      new(value).freeze
    end

    def generate count = 1, prefix: nil, prefix_length: nil
      if prefix == nil
        if prefix_length != nil
          raise ArgumentError, "Prefix length must be Integer < #{ BYTES }!", caller unless Integer === prefix_length && prefix_length < BYTES
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
      result = count.times.map { parse(prefix + SecureRandom.hex(BYTES - prefix_length)) }
      if count == 1
        result[0]
      else
        result
      end
    end

    def make *args
      raise ArgumentError, "Method receives 1..5 arguments!", caller unless (1..5) === args.size
      raise ArgumentError, "Arguments must be Integers!", caller     unless args.all? { |a| Integer === a }
      last = args.pop
      value = 0
      value += args[0] << 12 * 8 if args.size > 0
      value += args[1] << 10 * 8 if args.size > 1
      value += args[2] <<  8 * 8 if args.size > 2
      value += args[3] <<  6 * 8 if args.size > 3
      value += last
      new(value).freeze
    end

  end

  ZERO = make 0

  def to_i
    @value
  end

  def to_s
    raw = @value.to_s(BASE)
    raw = '0' * (DIGITS - raw.length) + raw if raw.length < DIGITS
    "#{ raw[0..7] }-#{ raw[8..11] }-#{ raw[12..15] }-#{ raw[16..19] }-#{ raw[20..31] }"
  end

  def inspect
    to_s
  end

  include Comparable

  def <=> other
    return nil unless UUID === other
    @value <=> other.value
  end

end
