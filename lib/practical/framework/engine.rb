# frozen_string_literal: true

module Practical
  module Framework
    class Engine < ::Rails::Engine
      config.app_generators do |g|
        g.apply_rubocop_autocorrect_after_generate!
        g.test_framework :test_unit, fixture: false, fixture_replacement: :oaken
      end

      # Hopefully can be removed in the future: https://github.com/rails/rails/issues/39522
      module PracticalFrameworkFormBuilderActiveSupportExtension
        def practical_form_with(**args, &block)
          original_field_error_proc = ::ActionView::Base.field_error_proc
          ::ActionView::Base.field_error_proc = ->(html_tag, instance) { html_tag }
          content_tag(:"practical-framework-error-handling") do
            form_with(**args, &block)
          end
        ensure
          ::ActionView::Base.field_error_proc = original_field_error_proc
        end
      end

      initializer 'practical-framework.view_helpers' do
        ActiveSupport.on_load(:action_view) do
          include Practical::Framework::Engine::PracticalFrameworkFormBuilderActiveSupportExtension
          include Practical::Helpers::FormWithHelper
          include Practical::Helpers::IconHelper
          include Practical::Helpers::TextHelper
          include Practical::Helpers::TranslationHelper
        end
      end
    end
  end
end
