# frozen_string_literal: true

class Practical::Loaders::Base
  include Pagy::Backend

  attr_accessor :params, :base_relation, :datatable_form, :relation_builder, :pagy_instance, :records

  def initialize(params:, base_relation:)
    self.params = params
    self.base_relation = base_relation
  end

  def self.load(params:, base_relation:)
    instance = self.new(params: params, base_relation: base_relation)
    instance.load
    return instance
  end

  def load
    self.datatable_form = build_datatable_form
    self.relation_builder = build_relation_builder
    self.pagy_instance, self.records = pagy(relation_builder.applied_relation, overflow: :last_page)
  end

  def datatable_payload
    (datatable_params[:datatable] || default_payload)
  end

  def datatable_params
    params.permit(datatable: [:sort_key, :sort_direction, filters: {}])
  end

  def build_datatable_form
    raise NotImplementedError
  end

  def build_relation_builder
    raise NotImplementedError
  end

  def default_payload
    raise NotImplementedError
  end
end