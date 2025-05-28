# frozen_string_literal: true

module Practical::Helpers::TranslationHelper
  def guided_translate(key, **options)
    new_options = options.reverse_merge(
      default: []
    )

    if key.start_with?(".")
      path_parts = controller_path.split("/")
      namespaced_versions = path_parts.each_with_index
                                      .map{|part, i| path_parts[0..i]}
                                      .map{|x| :"#{x.join(".")}#{key}"}

      guided_defaults = [
        namespaced_versions,
        key[1..].to_sym
      ].flatten

      new_options[:default] += guided_defaults
    end

    t(key, **new_options)
  end
end
