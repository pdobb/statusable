# frozen_string_literal: true

# Statusable::HasStatuses adds a `has_statuses` macro for defining common
# status-related methods around the passed in list of status names for the given
# {#col_name}.
#
# Optional validations exist as well. By default, inclusion is required, but
# presence is not.
module Statusable::HasStatuses
  extend ActiveSupport::Concern

  class_methods do # rubocop:disable Metrics/BlockLength
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Naming/PredicateName
    def has_statuses(
          *args,
          col_name: "status",
          validate_presence: false,
          validate_inclusion: true)
      statuses = args.flatten.freeze
      pluralized_column_name = col_name.to_s.pluralize
      arel_column = arel_table[col_name]

      humanized_statuses_list =
        statuses.to_sentence(
          two_words_connector: " or ",
          last_word_connector: ", or ").
          freeze

      if validate_presence
        validates(
          col_name,
          presence: true)
      end

      if validate_inclusion
        validates(
          col_name,
          inclusion: {
            in: statuses,
            allow_blank: true,
            message: "must be one of #{humanized_statuses_list}",
          })
      end

      # .for_status(<status>)
      scope "for_#{col_name}",
            ->(status) {
              where(
                if status.is_a?(Array)
                  arel_column.in(status)
                else
                  arel_column.eq(status)
                end)
            }

      # .not_for_status(<status>)
      scope "not_for_#{col_name}",
            ->(status) {
              where(
                if status.is_a?(Array)
                  arel_column.not_in(status)
                else
                  arel_column.not_eq(status)
                end)
            }

      # .by_status_asc
      scope "by_#{col_name}_asc",
            -> { order(arel_column) }

      # .by_status_desc
      scope "by_#{col_name}_desc",
            -> { order(arel_column.desc) }

      # .group_by_status
      scope "group_by_#{col_name}",
            -> { group(arel_column) }

      # Class method to get a humanized list of statuses.
      # .humanized_statuses_list
      define_singleton_method(:"humanized_#{pluralized_column_name}_list") do
        humanized_statuses_list
      end

      # Instance method to get a humanized list of statuses.
      # #humanized_statuses_list
      define_method(:"humanized_#{pluralized_column_name}_list") do
        humanized_statuses_list
      end

      # Class method to get all options for <col_name>.
      # .status_options
      define_singleton_method(:"#{col_name}_options") do
        statuses
      end

      # Instance method to get all options for <col_name>.
      # #status_options
      define_method(:"#{col_name}_options") do
        statuses
      end

      # #status?("Ready")
      # #status?(["Ready", "Not Ready"])
      define_method(:"#{col_name}?") do |a_status|
        Array(a_status).any?(public_send(col_name))
      end

      # #not_status?("Ready")
      define_method(:"not_#{col_name}?") do |a_status|
        public_send(col_name) != a_status
      end

      statuses.each do |status| # rubocop:disable Metrics/BlockLength
        status_name = status.parameterize.underscore

        # .for_status_ready
        scope "for_#{col_name}_#{status_name}",
              -> { where(arel_column.eq(status)) }

        # .not_for_status_ready
        scope "not_for_#{col_name}_#{status_name}",
              -> { where(arel_column.not_eq(status)) }

        # Class method to get <status_name> value. Obviates the need for
        # defining a constant.
        # .status_ready  # => "Ready"
        define_singleton_method(:"#{col_name}_#{status_name}") do
          status
        end

        # Instance method to get <status_name> value. Obviates the need for
        # defining a constant.
        # #status_ready  # => "Ready"
        define_method(:"#{col_name}_#{status_name}") do
          status
        end

        # @return [self]
        # #set_status_ready
        define_method(:"set_#{col_name}_#{status_name}") do
          public_send(:"#{col_name}=", status)

          self
        end

        # #set_status_ready!
        # @return [self]
        define_method(:"set_#{col_name}_#{status_name}!") do
          public_send(:"set_#{col_name}_#{status_name}")
          save!

          self
        end

        # #status_ready?
        define_method(:"#{col_name}_#{status_name}?") do
          public_send(col_name) == status
        end

        # #not_status_ready?
        define_method(:"not_#{col_name}_#{status_name}?") do
          public_send(col_name) != status
        end
      end
    end
    # rubocop:enable Naming/PredicateName
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize
  end
end
