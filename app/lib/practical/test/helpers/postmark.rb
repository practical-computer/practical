# frozen_string_literal: true

module Practical::Test::Helpers::Postmark
  def extract_template_model(mail:)
    scanner = StringScanner.new(mail.body.encoded)
    scanner.skip_until(/Model:\r\n/)

    result = scanner.scan_until(/^Use the #prerender/)
    return JSON.parse(result.gsub("Use the #prerender", ''))
  end
end