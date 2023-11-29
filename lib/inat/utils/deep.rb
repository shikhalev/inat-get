# frozen_string_literal: true

# TODO: убрать, все равно конфиг надо парсить нормально

module DeepMerge

  refine Hash do

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

  refine Array do

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

end
