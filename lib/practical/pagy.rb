# frozen_string_literal: true

require 'pagy/toolbox/helpers/support/series'

module ExposePagySeriesModule # wrap it with your arbitrarily named module
  def series
    super
  end
end
# prepend your module to the overridden module
Pagy.prepend ExposePagySeriesModule