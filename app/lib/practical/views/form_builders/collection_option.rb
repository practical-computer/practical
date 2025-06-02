# frozen_string_literal: true

module Practical::Views::FormBuilders
  CollectionOption = Struct.new(:value, :title, :description, :icon, keyword_init: true)
end