# frozen_string_literal: true

#
# Ransack 4 requires models to explicitly allowlist which attributes and
# associations may be used in searches. ActiveAdmin's filter UI relies on
# this. Admin-only UI, so allowlisting all columns is acceptable here.
#
module RansackAllowlist
  extend ActiveSupport::Concern

  class_methods do
    def ransackable_attributes(_auth_object = nil)
      column_names + _ransackers.keys
    end

    def ransackable_associations(_auth_object = nil)
      reflect_on_all_associations.map { |a| a.name.to_s }
    end
  end
end
