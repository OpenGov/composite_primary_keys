module ActiveRecord
  module Associations
    class HasManyThroughAssociation
      def construct_join_attributes(*records)
        ensure_mutable

        association_fk = Array(source_reflection.foreign_key)
        association_pk = Array(source_reflection.association_primary_key(reflection.klass))

        join_fields = association_fk.zip(association_pk)

        table = Arel::Table.new(through_association.scoped.table_name)
        and_conditions = records.map do |record|
          eq_conditions = join_fields.map do |to, from|
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
    end
  end
end