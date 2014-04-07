module ActiveRecord
  module AttributeMethods
    module Dirty
      def write_attribute(attr, value)
        # CPK
        if attr.kind_of?(Array)
          # To be safe, mark attributes as dirty
          value = [nil] * attr.length if value.nil?
          attr.zip(value).each { |a, v| mark_dirty(a, v) }
        else
          mark_dirty(attr, value)
        end

        # Carry on.
        super(attr, value)
      end

      private

      def mark_dirty(attr, value)
        attr = attr.to_s

        # The attribute already has an unsaved change.
        if attribute_changed?(attr)
          old = @changed_attributes[attr]
          @changed_attributes.delete(attr) unless _field_changed?(attr, old, value)
        else
          old = clone_attribute_value(:read_attribute, attr)
          # Save Time objects as TimeWithZone if time_zone_aware_attributes == true
          old = old.in_time_zone if clone_with_time_zone_conversion_attribute?(attr, old)
          @changed_attributes[attr] = old if _field_changed?(attr, old, value)
        end
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  alias :[]= :write_attribute
  public :[]=
end
