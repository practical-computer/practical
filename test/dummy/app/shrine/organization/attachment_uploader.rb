# frozen_string_literal: true

class Organization::AttachmentUploader < Shrine
  Attacher.validate do
    validate_max_size Practical::Defaults::Shrine.max_file_size
    validate_mime_type Practical::Defaults::Shrine.mime_types
    validate_extension Practical::Defaults::Shrine.extensions
  end
end