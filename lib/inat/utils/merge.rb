# frozen_string_literal: true

module DeepMerge

  refine Hash do

    def deep_merge! other
      other.each do |key, value|
        key = key.to_sym if String === key
        if has_key?(key) && self[key].respond_to?(:deep_merge!)
          self[key].deep_merge! value
        else
          if value.respond_to?(:deep_clone)
            value = value.deep_clone
          end
          self[key] = value
        end
      end
      self
    end

    def deep_clone
      result = {}
      each do |key, value|
        if value.respond_to?(:deep_clone)
          value = value.deep_clone
        end
        result[key] = value
      end
      result
    end

    def deep_merge other
      result = deep_clone
      result.deep_merge! other
    end

  end

  refine Array do

    def deep_merge! other
      other.each do |value|
        if !self.include?(value)
          if value.respond_to?(:deep_clone)
            value = value.deep_clone
          end
          self << value
        end
      end
      self
    end

    def deep_clone
      result = []
      each do |value|
        if value.respond_to?(:deep_clone)
          value = value.deep_clone
        end
        result << value
      end
      result
    end

  end

end
