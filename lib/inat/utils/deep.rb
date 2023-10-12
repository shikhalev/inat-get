# frozen_string_literal: true

class Hash

  def deep_merge! other
    other.each do |key, value|
      if has_key?(key) && self[key].respond_to?(:deep_merge!)
        self[key].deep_merge! value
      else
        self[key] = value
      end
    end
    self
  end

end

class Array

  def deep_merge! other
    other.each do |value|
      next if self.include?(value)
      next if String === value && self.include?(value.intern)
      next if Symbol === value && self.include?(value.to_s)
      self << value
    end
    self
  end

end
