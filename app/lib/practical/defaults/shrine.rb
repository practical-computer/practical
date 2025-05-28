# frozen_string_literal: true

module Practical::Defaults::Shrine
  def self.max_file_size
    (20*1024*1024).freeze # 20 MB
  end

  def self.mime_types
    %w(image/jpeg
        image/png
        image/webp
        image/tiff
        image/gif
        image/heic
        text/csv
        application/pdf
        application/vnd.openxmlformats-officedocument.wordprocessingml.document
        application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
        application/msword
        application/vnd.ms-excel
        text/plain
        application/rtf
        text/rtf
        application/vnd.apple.numbers
    ).freeze
  end

  def self.extensions
    %w(jpg
       jpeg
       png
       webp
       tiff
       tif
       gif
       heic
       csv
       pdf
       docx
       xlsx
       doc
       xls
       txt
       rtf
       numbers
    ).freeze
  end
end