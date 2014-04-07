module ActiveRecord
  module Associations
    class HasManyThroughAssociation
      def construct_join_fields
        [Array(source_reflection.foreign_key), Array(source_reflection.association_primary_key(reflection.klass))]
      end

      def construct_join_attributes(*records)
        ensure_mutable

        association_fk, association_pk = construct_join_fields
        paired_join_fields = association_fk.zip(association_pk)

        table = Arel::Table.new(through_association.scoped.table_name)
        and_conditions = records.map do |record|
          eq_conditions = paired_join_fields.map do |to, from|
            table[to].eq(record[from])
          end
          Arel::Nodes::And.new(eq_conditions)
        end

        condition = and_conditions.shift
        and_conditions.each do |and_condition|
          condition = condition.or(and_condition)
        end

        condition
      end

      def through_records_for(record)
        association_fk, association_pk = construct_join_fields
        record_attributes = record.attributes.slice(*association_pk)
        candidates = Array.wrap(through_association.target)
        candidates.find_all { |c| c.attributes.slice(*association_fk) == record_attributes }
      end
    end
  end
end