module ActiveModel
  module Dirty
    def can_change_primary_key?
      true
    end

    def primary_key_changed?
      !!changed.detect { |key| ids_hash.keys.include?(key.to_s) }
    end

    def primary_key_was
      ids_hash.keys.inject(Hash.new) do |result, attribute_name|
        prev_val = attribute_was(attribute_name.to_s)
        if attribute_name == 'id'
          id_index = self.class.primary_key.index('id')
          result['id'] = prev_val[id_index]
        else
          result[attribute_name] = prev_val
        end
        result
      end
    end
    alias_method :ids_hash_was, :primary_key_was
  end
end
