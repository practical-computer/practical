# frozen_string_literal: true

class Practical::Loaders::Base
  include Pagy::Method

  attr_accessor :request, :base_relation, :datatable_form,
                :relation_builder, :pagy_instance, :records

  delegate :params, to: :request

  def initialize(request:, base_relation:)
    self.request = request
    self.base_relation = base_relation
  end

  def self.load(request:, base_relation:)
    instance = self.new(request: request, base_relation: base_relation)
    instance.load
    return instance
  end

  def load
    self.datatable_form = build_datatable_form
    self.relation_builder = build_relation_builder
    self.pagy_instance, self.records = pagy(relation_builder.applied_relation)
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

  def params
    return request.params if request.params.kind_of?(ActionController::Parameters)
    return ActionController::Parameters.new(request.params)
  end
end