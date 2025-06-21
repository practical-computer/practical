# frozen_string_literal: true

class Practical::Views::Navigation::PaginationComponent < ApplicationComponent
  include Pagy::Frontend
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
      key = "pagy.info.no_items"
    elsif pagy.pages == 1
      key = "pagy.info.single_page"
    else
      key = "pagy.info.multiple_pages"
    end

    item_name = item_name.presence || pagy_t(i18n_key || pagy.vars[:i18n_key], count: pagy_count)

    item_text = pagy_t(key,
                       item_name: item_name,
                       count: pagy_count, from: pagy.from, to: pagy.to
    )

    page_count_text = pagy_t("pagy.info.page_count", page: pagy.page, count: pagy.pages)

    return pagy_t("pagy.info.page_detail_text", item_text: item_text, page_count_text: page_count_text)
  end

  def previous_item
    classes = helpers.class_names(:page, :previous, disabled: !pagy.prev)

    text = icon_text(
      icon: icon_set.previous_arrow,
      text: pagy_t('pagy.nav.prev')
    )

    tag.div(class: classes, role: :listitem){
      if pagy.prev
        tag.a(href: pagy_url_for(pagy, pagy.prev), title: pagy_t("pagy.nav.prev_page_title")) {
          text
        }
      else
        text
      end
    }
  end

  def next_item
    classes = helpers.class_names(:page, :next, disabled: !pagy.next)

    text = icon_text(
      icon: icon_set.next_arrow,
      text: pagy_t('pagy.nav.next')
    )

    tag.div(class: classes, role: :listitem){
      if pagy.next
        tag.a(href: pagy_url_for(pagy, pagy.next), title: pagy_t("pagy.nav.next_page_title")) {
          text
        }
      else
        text
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
        tag.a(item, href: pagy_url_for(pagy, item), title: pagy_t("pagy.nav.page_title", page_number: item))
      }
    when String
      tag.div(
        item,
        class: "page current", role: :listitem, title: pagy_t("pagy.nav.current_page_title", page_number: item)
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
