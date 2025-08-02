# frozen_string_literal: true

require 'view_component'

class Practical::Views::ComponentGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  class_option :parent, default: "Practical::Views::BaseComponent"
  class_option :view_component, type: :boolean, default: true

  def prepare_name
    unless class_name.start_with? "Practical::Views"
      self.name = "practical/views/#{name}"
    end
  end

  hook_for :view_component, in: :rails, type: :boolean do |instance, generator_klass|
    instance.invoke generator_klass, [ instance.name, *instance.args], instance.options
  end
end
