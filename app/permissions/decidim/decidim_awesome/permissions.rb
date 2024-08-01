# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return permission_action unless user

        return Decidim::DecidimAwesome::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin

        editor_image_action?

        permission_action
      end

      def editor_image_action?
        return false unless permission_action.subject == :editor_image

        config = context.fetch(:awesome_config, {})

        return allow! if user.admin?
        return allow! if config[:allow_images_in_proposals]
        return allow! if config[:allow_images_in_editors]
        return allow! if config[:allow_videos_in_editors]
      end
    end
  end
end
