# frozen_string_literal: true

class Practical::Views::IconForFileExtensionComponent < Practical::Views::BaseComponent
  attr_reader :extension

  def initialize(extension:)
    raise ArgumentError unless self.class.supported_extension?(extension: extension)
    @extension = extension.to_sym
  end

  def call
    case extension
    when :csv
      render_icon(method_name: :csv_icon)
    when :pdf
      render_icon(method_name: :pdf_icon)
    when :doc, :docx
      render_icon(method_name: :doc_icon)
    when :xls, :xlsx
      render_icon(method_name: :xls_icon)
    when :heic
      render_icon(method_name: :heic_icon)
    when :missing
      render_icon(method_name: :missing_file_icon)
    else
      render_icon(method_name: :txt_icon)
    end
  end

  def render_icon(method_name:)
    render icon_set.public_send(method_name)
  end

  def self.supported_extension?(extension:)
    supported_extensions.include?(extension.to_sym)
  end

  def self.supported_extensions
    %i(
       csv
       pdf
       docx
       xlsx
       doc
       xls
       heic
       missing
       txt
       rtf
       numbers
    ).freeze
  end
end
