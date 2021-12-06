# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      # Global configuration controller
      class CustomRegistrationFormController < DecidimAwesome::Admin::ConfigController
        def create
          CreateCustomRegistrationField.call(current_organization) do
            on(:ok) do |key|
              flash[:notice] = I18n.t("config.create_custom_registration_field.success", key: key, scope: "decidim.decidim_awesome.admin")
            end

            on(:invalid) do |message|
              flash[:alert] = I18n.t("config.create_custom_registration_field.error", error: message, scope: "decidim.decidim_awesome.admin")
            end
          end

          redirect_to decidim_admin_decidim_awesome.config_path(:custom_registration_form)
        end

        def destroy
          DestroyProposalCustomField.call(params[:key], current_organization) do
            on(:ok) do |key|
              flash[:notice] = I18n.t("config.destroy_proposal_custom_field.success", key: key, scope: "decidim.decidim_awesome.admin")
            end

            on(:invalid) do |message|
              flash[:alert] = I18n.t("config.destroy_proposal_custom_field.error", error: message, scope: "decidim.decidim_awesome.admin")
            end
          end

          redirect_to decidim_admin_decidim_awesome.config_path(:custom_registration_form)
        end
      end
    end
  end
end
