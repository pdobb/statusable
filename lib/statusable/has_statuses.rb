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
    # :reek:TooManyStatements
    # :reek:LongParameterList
    # :reek:BooleanParameter
    # :reek:ControlParameter
    # :reek:DuplicateMethodCall
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

      # VALIDATIONS

      # Define a presence validation on the given `col_name`, if requested.
      if validate_presence # rubocop:disable Style/IfUnlessModifier
        validates(col_name, presence: true)
      end

      # Define an inclusion validation on the given `col_name` based on the
      # givien list of `statuses`, if requested.
      if validate_inclusion
        message = "must be one of #{humanized_statuses_list}"
        validates(
          col_name,
          inclusion: { in: statuses, allow_blank: true, message: message })
      end

      # NAMED SCOPES

      # Define a named scope that filters on `col_name` records.
      #
      # @attr status [String, Array[String]]
      #
      # @example Default `col_name`
      #   .for_status(<a_status_name>)
      #
      # @example Custom `col_name`
      #   .for_custom_col_name(<a_status_name>)
      scope :"for_#{col_name}", ->(status) {
        method_name = status.is_a?(Array) ? :in : :eq
        where(arel_column.public_send(method_name, status))
      }

      # Define a named scope that filters out `col_name` records.
      #
      # @attr status [String, Array[String]]
      #
      # @example Default `col_name`
      #   .not_for_status(<a_status_name>)
      #
      # @example Custom `col_name`
      #   .not_for_custom_col_name(<a_status_name>)
      scope :"not_for_#{col_name}", ->(status) {
        method_name = status.is_a?(Array) ? :not_in : :not_eq
        where(arel_column.public_send(method_name, status))
      }

      # Define a named scope that orders by `col_name`, ascending.
      #
      # @example Default `col_name`
      #   .by_status_asc
      #
      # @example Custom `col_name`
      #   .by_custom_col_name_asc
      scope :"by_#{col_name}_asc", -> { order(arel_column) }

      # Define a named scope that orders by `col_name`, descending.
      #
      # @example Default `col_name`
      #   .by_status_desc
      #
      # @example Custom `col_name`
      #   .by_custom_col_name_desc
      scope :"by_#{col_name}_desc", -> { order(arel_column.desc) }

      # Define a named scope that groups by `col_name`, ascending.
      #
      # @example Default `col_name`
      #   .group_by_status
      #
      # @example Custom `col_name`
      #   .group_by_custom_col_name
      scope :"group_by_#{col_name}", -> { group(arel_column) }

      # CLASS METHODS

      # Define a class method that returns the `statuses` Array.
      #
      # @return [Array[String]]
      #
      # @example Default `col_name`
      #   .status_options          # => ["Status 1", "Status 2"]
      #
      # @example Custom `col_name`
      #   .custom_col_name_options # => ["Custom 1", "Custom 2"]
      define_singleton_method(:"#{col_name}_options") do
        statuses
      end

      # Define a class method that returns a humanized list of `statuses`.
      #
      # @return [String]
      #
      # @example Default `col_name`
      #   .humanized_statuses_list # => "Status 1, Status 2, or Status 3"
      #
      # @example Custom `col_name`
      #   .humanized_custom_col_name_list # => "Custom 1, Custom 2, or Custom 3"
      define_singleton_method(:"humanized_#{pluralized_column_name}_list") do
        humanized_statuses_list
      end

      # INSTANCE METHODS

      # Define an instance method that returns the `statuses` Array.
      #
      # @return [Array[String]]
      #
      # @example Default `col_name`
      #   #status_options          # => ["Status 1", "Status 2"]
      #
      # @example Custom `col_name`
      #   #custom_col_name_options # => ["Custom 1", "Custom 2"]
      define_method(:"#{col_name}_options") do
        statuses
      end

      # Define an instance method that returns a humanized list of `statuses`.
      #
      # @return [String]
      #
      # @example Default `col_name`
      #   #humanized_statuses_list # => "Status 1, Status 2, or Status 3"
      #
      # @example Custom `col_name`
      #   #humanized_custom_col_name_list # => "Custom 1, Custom 2, or Custom 3"
      define_method(:"humanized_#{pluralized_column_name}_list") do
        humanized_statuses_list
      end

      # Define an instance method that checks whether:
      # - The current `status` is the same as the given status
      # - The current `status` is the same as any of the given statuses
      #
      # @return [Boolean]
      #
      # @example Default `col_name`
      #   #status?("Known Status") # => true
      #   #status?("Unknown Status") # => false
      #   #status?(["Known Status 1", "Unknown Status 1"]) # => true
      #   #status?(["Unknown Status 1", "Unknown Status 2"]) # => false
      #
      # @example Custom `col_name`
      #   #custom_col_name?("Known Custom") # => true
      #   #custom_col_name?("Unknown Custom") # => false
      #   #custom_col_name?(["Known Custom 1", "Unknown Custom 1"]) # => true
      #   #custom_col_name?(["Unknown Custom 1", "Unknown Custom 2"]) # => false
      define_method(:"#{col_name}?") do |a_status|
        Array(a_status).any?(public_send(col_name))
      end

      # rubocop:disable Layout/LineLength

      # Define an instance method that checks whether:
      # - The current `status` is not the same as given status
      # - The current `status` is not the same as any of the given statuses
      #
      # @return [Boolean]
      #
      # @example Default `col_name`
      #   #not_status?("Known Status") # => false
      #   #not_status?("Unknown Status") # => true
      #   #not_status?(["Known Status 1", "Unknown Status 1"]) # => false
      #   #not_status?(["Unknown Status 1", "Unknown Status 2"]) # => true
      #
      # @example Custom `col_name`
      #   #not_custom_col_name?("Known Custom") # => false
      #   #not_custom_col_name?("Unknown Custom") # => true
      #   #not_custom_col_name?(["Known Custom 1", "Unknown Custom 1"]) # => false
      #   #not_custom_col_name?(["Unknown Custom 1", "Unknown Custom 2"]) # => true
      define_method(:"not_#{col_name}?") do |a_status|
        Array(a_status).none?(public_send(col_name))
      end

      # rubocop:enable Layout/LineLength

      # INDIVIDUAL STATUS-SPECIFIC SCOPES/METHODS

      statuses.each do |status| # rubocop:disable Metrics/BlockLength
        status_name = status.parameterize.underscore

        # NAMED SCOPES

        # Define a named scope that filters on `col_name` records that match
        # this `status`.
        #
        # @example Default `col_name`
        #   .for_status_ready
        #   .for_status_not_ready
        #
        # @example Custom `col_name`
        #   .for_custom_col_name_custom_1
        #   .for_custom_col_name_custom_2
        scope :"for_#{col_name}_#{status_name}",
              -> { where(arel_column.eq(status)) }

        # Define a named scope that filters on `col_name` records that do not
        # match this `status`.
        #
        # @example Default `col_name`
        #   .not_for_status_ready
        #   .not_for_status_not_ready
        #
        # @example Custom `col_name`
        #   .not_for_custom_col_name_custom_1
        #   .not_for_custom_col_name_custom_2
        scope :"not_for_#{col_name}_#{status_name}",
              -> { where(arel_column.not_eq(status)) }

        # CLASS METHODS

        # Define a class method that returns this `status`'s value. This
        # obviates the need to define a constant on the including Class.
        #
        # @return [String]
        #
        # @example Default `col_name`
        #   .status_ready     # => "Ready"
        #   .status_not_ready # => "Not Ready"
        #
        # @example Custom `col_name`
        #   .custom_col_name_custom_1 # => "Custom 1"
        #   .custom_col_name_custom_2 # => "Custom 2"
        define_singleton_method(:"#{col_name}_#{status_name}") do
          status
        end

        # Define an instance method that returns this `status`'s value. This
        # obviates the need to call e.g.
        #  - `self.class::STATUS_READY`
        #  - `self.class.status_ready`
        # on the including Object.
        #
        # @return [String]
        #
        # @example Default `col_name`
        #   #status_ready     # => "Ready"
        #   #status_not_ready # => "Not Ready"
        #
        # @example Custom `col_name`
        #   #custom_col_name_custom_1 # => "Custom 1"
        #   #custom_col_name_custom_2 # => "Custom 2"
        define_method(:"#{col_name}_#{status_name}") do
          status
        end

        # Define an instance method that sets this `status`'s value. This
        # obviates the need to call e.g. `self.status = status_not_ready` on the
        # including Object.
        #
        # @return [self]
        #
        # @example Default `col_name`
        #   #set_status_ready.status     # => "Ready"
        #   #set_status_not_ready.status # => "Not Ready"
        #
        # @example Custom `col_name`
        #   #set_custom_col_name_custom_1.custom_col_name # => "Custom 1"
        #   #set_custom_col_name_custom_2.custom_col_name # => "Custom 2"
        define_method(:"set_#{col_name}_#{status_name}") do
          public_send(:"#{col_name}=", status)

          self
        end

        # Define an instance method that sets this `status`'s value, and then
        # calls ActiveRecord::Persistence#save!. This obviates the need to call
        # e.g. `self.status = status_not_ready; save!` on the including Object.
        #
        # @return [self]
        #
        # @example Default `col_name`
        #   #set_status_ready!.status # => "Ready"
        #   #changes                  # => {}
        #
        #   #set_status_not_ready!.status # => "Not Ready"
        #   #changes                      # => {}
        #
        # @example Custom `col_name`
        #   #set_custom_col_name_custom_1!.custom_col_name # => "Custom 1"
        #   #changes                  # => {}
        #
        #   #set_custom_col_name_custom_2!.custom_col_name # => "Custom 2"
        #   #changes                  # => {}
        define_method(:"set_#{col_name}_#{status_name}!") do
          public_send(:"set_#{col_name}_#{status_name}")
          save!

          self
        end

        # Define an instance method that checks whether the current `status` is
        # the same as the status named by this method name. This obviates the
        # need to call e.g. `status == status_ready` on the including Object.
        #
        # @return [Boolean]
        #
        # @example Default `col_name`
        #   #status_ready?     # => true
        #   #status_not_ready? # => false
        #
        # @example Custom `col_name`
        #   #custom_col_name_custom_1? # => true
        #   #custom_col_name_custom_2? # => false
        define_method(:"#{col_name}_#{status_name}?") do
          public_send(col_name) == status
        end

        # Define an instance method that checks whether the current `status` is
        # not the same as the status named by this method name. This obviates
        # the need to call e.g. `status != status_ready` on the including
        # Object.
        #
        # @return [Boolean]
        #
        # @example Default `col_name`
        #   #not_status_ready?     # => false
        #   #not_status_not_ready? # => true
        #
        # @example Custom `col_name`
        #   #not_custom_col_name_custom_1? # => false
        #   #not_custom_col_name_custom_2? # => true
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
