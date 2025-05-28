# frozen_string_literal: true

class Practical::Views::TiptapDocumentComponent < Practical::Views::BaseComponent
  class UnknownNodeTypeError < StandardError; end
  class UnknownMarkupTypeError < StandardError; end

  module NodeRendering
    def render_node(node:)
      case node[:type].to_sym
      when :text
        render Text.new(node_content: node)
      when :paragraph
        render Paragraph.new(node_content: node)
      when :heading
        render Heading.new(node_content: node)
      when :codeBlock
        render CodeBlock.new(node_content: node)
      when :listItem
        render ListItem.new(node_content: node)
      when :bulletList
        render UnorderedList.new(node_content: node)
      when :orderedList
        render OrderedList.new(node_content: node)
      when :"attachment-figure", :"previewable-attachment-figure"
        render Attachment.new(node_content: node)
      when :blockquote
        render Blockquote.new(node_content: node)
      when :hardBreak
        render HardBreak.new(node_content: node)
      else
        raise UnknownNodeTypeError
      end
    end
  end

  include NodeRendering

  attr_reader :document

  def initialize(document:)
    raise ArgumentError if document["type"] != "doc"
    @document = document.with_indifferent_access
  end

  def call
    safe_join([document[:content].map do |node|
      render_node(node: node)
    end])
  end

  class Node < Practical::Views::BaseComponent
    include NodeRendering

    attr_reader :node_content

    def initialize(node_content:)
      @node_content = node_content
    end

    def render_node_contents
      if node_content.present? && node_content[:content].present?
        safe_join(node_content[:content].map{|node| render_node(node: node)})
      end
    end
  end

  class HardBreak < Node
    def call
      tag.br
    end
  end

  class Text < Node
    SORTED_MARKUP_TYPES = [
      "rhino-strike", "link", "bold", "italic"
    ].freeze

    def applicable_markup_types
      SORTED_MARKUP_TYPES.select{|type| node_content[:marks].any?{ |mark| mark[:type] == type }}
    end

    def call
      if node_content[:marks].present? && node_content[:marks].any?
        render_with_marks(markup_to_apply: applicable_markup_types)
      else
        render_plaintext
      end
    end

    def render_with_marks(markup_to_apply:)
      markup_type = markup_to_apply.shift
      case markup_type
      when "italic"
        tag.em{ render_with_marks(markup_to_apply: markup_to_apply) }
      when "bold"
        tag.strong { render_with_marks(markup_to_apply: markup_to_apply) }
      when "rhino-strike"
        tag.del { render_with_marks(markup_to_apply: markup_to_apply) }
      when "link"
        tag.a(**link_attributes) { render_with_marks(markup_to_apply: markup_to_apply) }
      when nil
        render_plaintext
      else
        raise UnknownMarkupTypeError
      end
    end

    def link_attributes
      node_content[:marks]&.find{|mark| mark[:type] == "link" }&.dig(:attrs)&.slice(:href, :target, :rel).to_h
    end

    def render_plaintext
      helpers.sanitize(node_content[:text])
    end
  end

  class Paragraph < Node
    def call
      tag.p {
        render_node_contents
      }
    end
  end

  class Heading < Node
    def call
      heading_element {
        render_node_contents
      }
    end

    def heading_element(&block)
      case node_content.dig(:attrs, :level)
      when 1
        tag.h1(&block)
      when 2
        tag.h2(&block)
      when 3
        tag.h3(&block)
      when 4
        tag.h4(&block)
      when 5
        tag.h5(&block)
      when 6
        tag.h6(&block)
      end
    end
  end

  class Blockquote < Node
    def call
      tag.blockquote {
        render_node_contents
      }
    end
  end

  class CodeBlock < Node
    def call
      tag.pre {
        tag.code { render_node_contents }
      }
    end
  end

  class ListItem < Node
    def call
      tag.li {
        render_node_contents
      }
    end
  end

  class UnorderedList < Node
    def call
      tag.ul {
        render_node_contents
      }
    end
  end

  class OrderedList < Node
    def call
      tag.ol(start: node_content.dig(:attrs, :start)) {
        render_node_contents
      }
    end
  end

  class Attachment < Node
    def call
      tag.figure(class: 'wa-stack wa-gap-s') {
        if missing_attachment?
          missing_attachment_figure
        else
          attachment_figure
        end
      }
    end

    def missing_attachment_figure
      safe_join([
        tag.div {
          render Practical::Views::IconForFileExtensionComponent.new(extension: "missing")
        },

        tag.section(class: 'attachment-details') {
          tag.p(t("tiptap_document.attachment_missing.text"))
        },

        figure_caption
      ])
    end

    def attachment_figure
      if previewable?
        image = tag.div {
          tag.img(src: url, width: width, height: height)
        }
      else
        image = tag.div {
          render Practical::Views::IconForFileExtensionComponent.new(extension: extension)
        }
      end

      safe_join([
        image,
        attachment_details_and_download,
        figure_caption
      ])
    end

    def figure_caption
      if node_content[:content].present?
        tag.figcaption { render_node_contents }
      end
    end

    def attachment_details_and_download
      tag.section(class: 'attachment-details') {
        tag.p {
          tag.a(href: url, target: "_blank") {
            "#{filename} – #{human_file_size}"
          }
        }
      }
    end

    def attachment
      @attachment ||= GlobalID::Locator.locate_signed(sgid.to_s, for: :document)&.attachment
    end

    def missing_attachment?
      attachment.nil?
    end

    def attrs
      node_content[:attrs]
    end

    def previewable?
      attrs.dig(:previewable)
    end

    def sgid
      attrs.dig(:sgid)
    end

    def filename
      attachment.original_filename
    end

    def human_file_size
      helpers.number_to_human_size(attachment.size)
    end

    def url
      attachment.url
    end

    def extension
      attachment.extension
    end

    def stored_width
      attrs.dig(:width)
    end

    def stored_height
      attrs.dig(:height)
    end

    def has_dimensions?
      !stored_width.blank? && !stored_height.blank?
    end

    def width
      return stored_width if has_dimensions?
      default_figure_size
    end

    def height
      return stored_height if has_dimensions?
      default_figure_size
    end

    def default_figure_size
      100
    end
  end
end
