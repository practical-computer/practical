# frozen_string_literal: true

require "shrine/storage/memory"

Shrine.storages = {
  cache: Shrine::Storage::Memory.new,
  store: Shrine::Storage::Memory.new
}

module Practical::Test::Helpers::Shrine::TestData
  def image_data
    attacher = Shrine::Attacher.new
    attacher.set(uploaded_image)

    attacher.data
  end

  def uploaded_image
    file = image_file
    uploaded_file = Shrine.upload(file, :store, metadata: false)
    uploaded_file.metadata.merge!(
      "size" => File.size(file.path),
      "mime_type" => "image/jpeg",
      "filenae" => "test.jpeg"
    )

    uploaded_file
  end

  def image_filepath
    file_fixture("dog.jpeg")
  end

  def image_file
    File.open(image_filepath)
  end

  def heic_filepath
    file_fixture("island.heic")
  end

  def heic_file
    File.open(heic_filepath)
  end

  def csv_filepath
    file_fixture("example.csv")
  end

  def csv_file
    File.open(csv_filepath)
  end

  def excel_filepath
    file_fixture("example.xlsx")
  end

  def excel_file
    File.open(excel_filepath)
  end

  def word_filepath
    file_fixture("example.docx")
  end

  def pdf_file
    File.open(pdf_filepath)
  end

  def pdf_filepath
    file_fixture("example.pdf")
  end

  def word_file
    File.open(word_filepath)
  end

  def numbers_filepath
    file_fixture("numbers-example.numbers")
  end

  def numbers_file
    File.open(numbers_filepath)
  end

  def plaintext_filepath
    file_fixture("example.txt")
  end

  def plaintext_file
    File.open(plaintext_filepath)
  end

  def rtf_filepath
    file_fixture("example.rtf")
  end

  def rtf_file
    File.open(rtf_filepath)
  end
end