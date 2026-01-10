# frozen_string_literal: true

class Practical::Views::Navigation::PaginationComponent < ApplicationComponent
  attr_reader :request
  attr_accessor :pagy, :item_name, :i18n_key

  def initialize(pagy:, request:, item_name: nil, i18n_key: nil)
    @pagy = pagy
    @request = request
    @item_name = item_name
    @i18n_key = i18n_key
  end

  def page_detail_text
    pagy_count = pagy.count
    if pagy_count == 0
      key = "pagy.info_tag.no_items"
    elsif pagy.pages == 1
      key = "pagy.info_tag.single_page"
    else
      key = "pagy.info_tag.multiple_pages"
    end

    item_name = item_name.presence || Pagy::I18n.translate(i18n_key || pagy.vars[:i18n_key], count: pagy_count)

    item_text = Pagy::I18n.translate(key,
                       item_name: item_name,
                       count: pagy_count, from: pagy.from, to: pagy.to
    )

    page_count_text = Pagy::I18n.translate("pagy.info_tag.page_count", page: pagy.page, count: pagy.pages)

    return Pagy::I18n.translate("pagy.info_tag.page_detail_text", item_text: item_text, page_count_text: page_count_text)
  end

  def previous_item
    classes = helpers.class_names(:page, :previous, disabled: !pagy.previous)

    tag.div(class: classes, role: :listitem){
      if pagy.previous
        tag.a(href: pagy.page_url(pagy.previous), title: Pagy::I18n.translate("pagy.aria_label.previous")) {
          render icon_set.previous_arrow
        }
      else
        render icon_set.previous_arrow
      end
    }
  end

  def next_item
    classes = helpers.class_names(:page, :next, disabled: !pagy.next)

    tag.div(class: classes, role: :listitem){
      if pagy.next
        tag.a(href: pagy.page_url(pagy.next), title: Pagy::I18n.translate("pagy.aria_label.next")) {
          render icon_set.next_arrow
        }
      else
        render icon_set.next_arrow
      end
    }
  end

  def goto_page_dialog_id
    return [item_name, "pagy-goto-form"].compact.join("-")
  end

  def page_item(item)
    case item
    when Integer
      tag.div(class: :page, role: :listitem) {
        tag.a(item, href: pagy.page_url(item), title: Pagy::I18n.translate("pagy.nav.page_title", page_number: item))
      }
    when String
      tag.div(
        item,
        class: "page current", role: :listitem, title: Pagy::I18n.translate("pagy.nav.current_page_title", page_number: item)
      )
    when :gap
      render Practical::Views::Navigation::Pagination::GotoFormComponent.new(
        pagy: pagy,
        dialog_id: goto_page_dialog_id,
        page_detail_text: page_detail_text
      )
    end
  end
end
