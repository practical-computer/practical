# frozen_string_literal: true

module Practical::Views::JSONRedirection
  def json_redirect(location:)
    render json: {location: location}, status: 322
  end
end