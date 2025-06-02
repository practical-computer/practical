# frozen_string_literal: true

module Practical::Test::Shared::Attachment::Model::Attachment
  extend ActiveSupport::Concern

  included do
    def assert_file_metadata(attachment:, file_size:, file_name:, mime_type:)
      assert_equal file_size, attachment.attachment.metadata["size"]
      assert_equal file_name, attachment.attachment.metadata["filename"]
      assert_equal mime_type, attachment.attachment.metadata["mime_type"]
    end

    def assert_file_type_support(file:, filepath:, mime_type:)
      file_size = File.size(filepath)
      file_name = File.basename(filepath)

      create_saved_attachment(file: file) do |attachment|
        assert_file_metadata(attachment: attachment,
                             file_size: file_size,
                             file_name: file_name,
                             mime_type: mime_type
                            )
      end
    end

    def assert_invalid_file_size_too_large(attachment:)
      assert_equal false, attachment.valid?
      assert_equal ["size must not be greater than 20.0 MB"], attachment.errors[:attachment]
    end

    def assert_invalid_incorrect_mime_type(attachment:)
      assert_equal false, attachment.valid?
      assert_match %r{type must be one of:}, attachment.errors[:attachment].first
    end

    test "saves the file under attachment_data" do
      assert_file_type_support(file: image_file,
                               filepath: image_filepath,
                               mime_type: "image/jpeg"
                              )
    end

    test "allows CSV attachments" do
      assert_file_type_support(file: csv_file,
                               filepath: csv_filepath,
                               mime_type: "text/csv"
                              )
    end

    test "allows PDF attachments" do
      assert_file_type_support(file: pdf_file,
                               filepath: pdf_filepath,
                               mime_type: "application/pdf"
                              )
    end

    test "allows Word attachments" do
      assert_file_type_support(file: word_file,
                               filepath: word_filepath,
                               mime_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
                              )
    end

    test "allows Excel attachments" do
      assert_file_type_support(file: excel_file,
                               filepath: excel_filepath,
                               mime_type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                              )
    end

    test "allows Numbers attachments" do
      assert_file_type_support(file: numbers_file,
                               filepath: numbers_filepath,
                               mime_type: "application/vnd.apple.numbers"
                              )
    end

    test "allows HEIC attachments" do
      assert_file_type_support(file: heic_file,
                               filepath: heic_filepath,
                               mime_type: "image/heic"
                              )
    end

    test "allows plain text attachments" do
      assert_file_type_support(file: plaintext_file,
                               filepath: plaintext_filepath,
                               mime_type: "text/plain"
                              )
    end

    test "allows RTF attachments" do
      assert_file_type_support(file: rtf_file,
                               filepath: rtf_filepath,
                               mime_type: "application/rtf"
                              )
    end

    test "limits attachments based on size" do
      file = image_file
      overage_file_size = 21*1024*1024 # 21 MB

      Spy.on(file, size: overage_file_size)

      attachment = build_new_attachment(file: file)

      assert_invalid_file_size_too_large(attachment: attachment)
    end

    test "does not allow attachments that are not of the correct MIME type" do
      Tempfile.open(%w(foo .jpg)) do |file|
        file.write SecureRandom.hex
        bad_mime_type = "application/x-sh"

        Spy.on(uploader_class, mime_type: "image/heic")

        attachment = build_new_attachment(file: file)

        assert_invalid_incorrect_mime_type(attachment: attachment)
      end
    end
  end
end