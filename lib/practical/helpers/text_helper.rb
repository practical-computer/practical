# frozen_string_literal: true

module Practical::Helpers::TextHelper
  def double_quoted_text(text)
    "“#{text}”"
  end

  def single_quoted_text(text)
    "‘#{text}’"
  end

  def initials(name:)
    space_split = name.split(" ")
    if space_split.size >= 2
      return space_split.first(2).map{|x| x[0]&.upcase }.join("")
    end

    return name.first(2).upcase
  end
end