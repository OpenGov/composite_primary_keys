module ActiveRecord
  module AttributeMethods
    module Write
      def write_attribute(attr_name, value)
        # CPK
        if attr_name.kind_of?(Array)
          value = [nil]*attr_name.length if value.nil?
          unless value.length == attr_name.length
            raise "Number of attr_names and values do not match"
          end

          attr_name[0..-2].each_with_index do |prop, index|
            prop_value = value[index]
            unless prop_value.nil? || prop_value == read_attribute(prop)
              raise "Assignment would augment the object's primary key"
            end
          end

          attr_name = attr_name[-1]
          value = value[-1]
        end

        attr_name = attr_name.to_s
        # CPK
        # attr_name = self.class.primary_key if attr_name == 'id' && self.class.primary_key
        attr_name = self.class.primary_key if attr_name == 'id' && self.class.primary_key && !self.composite?
        @attributes_cache.delete(attr_name)
        column = column_for_attribute(attr_name)

        unless column || @attributes.has_key?(attr_name)
          ActiveSupport::Deprecation.warn(
              "You're trying to create an attribute `#{attr_name}'. Writing arbitrary " \
              "attributes on a model is deprecated. Please just use `attr_writer` etc."
          )
        end

        @attributes[attr_name] = type_cast_attribute_for_write(column, value)
      end

      alias_method :raw_write_attribute, :write_attribute
    end
  end
end

ActiveRecord::Base.class_eval do
  alias_method :raw_write_attribute, :write_attribute
  alias :[]= :write_attribute
  public :[]=
end
