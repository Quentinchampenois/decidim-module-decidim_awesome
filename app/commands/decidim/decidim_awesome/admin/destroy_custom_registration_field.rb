# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class DestroyCustomRegistrationField < Rectify::Command
        # Public: Initializes the command.
        #
        # key - the key to destroy inise proposal_custom_fields
        # organization
        def initialize(key, organization)
          @key = key
          @organization = organization
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if we couldn't proceed.
        #
        # Returns nothing.
        def call
          fields = AwesomeConfig.find_by(var: :custom_registration_form, organization: @organization)
          return broadcast(:invalid, "Not a hash") unless fields&.value.is_a? Hash
          return broadcast(:invalid, "#{key} key invalid") unless fields.value.has_key?(@key)

          fields.value.except!(@key)
          fields.save!

          broadcast(:ok, @key)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end
      end
    end
  end
end
