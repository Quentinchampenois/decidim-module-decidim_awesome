# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class ConfigForm < Decidim::Form
        include ActionView::Helpers::SanitizeHelper

        attribute :allow_images_in_full_editor, Boolean
        attribute :allow_images_in_small_editor, Boolean
        attribute :allow_images_in_proposals, Boolean
        attribute :use_markdown_editor, Boolean
        attribute :allow_images_in_markdown_editor, Boolean
        attribute :auto_save_forms, Boolean
        attribute :scoped_styles, Hash
        attribute :proposal_custom_fields, Hash
        attribute :custom_registration_form, Hash
        attribute :scoped_admins, Hash
        attribute :menu, Array[MenuForm]
        attribute :intergram_for_admins, Boolean
        attribute :intergram_for_admins_settings, IntergramForm
        attribute :intergram_for_public, Boolean
        attribute :intergram_for_public_settings, IntergramForm

        # collect all keys anything not specified in the params (UpdateConfig command ignores it)
        attr_accessor :valid_keys

        validate :css_syntax, if: ->(form) { form.scoped_styles.present? }
        validate :proposal_custom_json_syntax, if: ->(form) { form.proposal_custom_fields.present? }
        validate :registration_form_json_syntax, if: ->(form) { form.custom_registration_form.present? }

        # TODO: validate non general admins are here

        def self.from_params(params, additional_params = {})
          instance = super(params, additional_params)
          instance.valid_keys = params.keys.map(&:to_sym) || []
          instance.sanitize_labels_for_proposals!
          instance.sanitize_labels_for_registration!
          instance
        end

        def css_syntax
          scoped_styles.each do |key, code|
            next unless code

            SassC::Engine.new(code).render
          rescue SassC::SyntaxError => e
            errors.add(:scoped_styles, I18n.t("config.form.errors.incorrect_css", key: key, scope: "decidim.decidim_awesome.admin"))
            errors.add(key.to_sym, e.message)
          end
        end

        def proposal_custom_json_syntax
          json_syntax(proposal_custom_fields)
        end

        def registration_form_json_syntax
          json_syntax(custom_registration_form)
        end

        def json_syntax(ary)
          ary&.each do |key, code|
            next unless code

            JSON.parse(code)
          rescue JSON::ParserError => e
            errors.add(:scoped_styles, I18n.t("config.form.errors.incorrect_json", key: key, scope: "decidim.decidim_awesome.admin"))
            errors.add(key.to_sym, e.message)
          end
        end

        def sanitize_labels_for_proposals!
          sanitize_labels_for! proposal_custom_fields
        end

        def sanitize_labels_for_registration!
          sanitize_labels_for! custom_registration_form
        end

        # formBuilder has a bug and do not sanitize text if users copy/paste text with format in the label input
        def sanitize_labels_for!(ary)
          return if ary.blank?

          ary.transform_values! do |code|
            next unless code

            json = JSON.parse(code)
            json.map! do |item|
              item["label"] = strip_tags(item["label"])
              item
            end
            JSON.generate(json)
          rescue JSON::ParserError
            code
          end
        end
      end
    end
  end
end
