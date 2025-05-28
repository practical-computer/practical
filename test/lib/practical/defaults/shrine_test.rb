# frozen_string_literal: true

require "test_helper"

class Practical::Defaults::ShrineTest < ActiveSupport::TestCase
  test "max_file_size" do
    assert_equal (20*1024*1024), Practical::Defaults::Shrine.max_file_size
  end

  test "mime_types" do
    expected = %w(image/jpeg
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
    )

    assert_equal expected, Practical::Defaults::Shrine.mime_types
  end

  test "extensions" do
    expected = %w(jpg
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

    assert_equal expected, Practical::Defaults::Shrine.extensions
  end
end