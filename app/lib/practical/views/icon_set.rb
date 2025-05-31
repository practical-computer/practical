# frozen_string_literal: true

class Practical::Views::IconSet
  IconDefinition = Data.define(:method_name, :icon_name, :preset)
  SpritesheetIconDefinition = Data.define(:method_name, :icon_name, :library)

  Preset = Data.define(:family, :variant)

  PRESETS = {
    brand: Preset.new(family: :brands, variant: nil),
    duotone: Preset.new(family: :duotone, variant: :solid),
    regular: Preset.new(family: :classic, variant: :regular),
    solid: Preset.new(family: :solid, variant: nil)
  }.freeze

  def self.presets
    PRESETS
  end

  def self.icon(**options)
    Practical::Views::IconComponent.new(**options)
  end

  def self.spritesheet_icon(library:, **options)
    Practical::Views::IconComponent.new(**options.with_defaults(
      family: :default,
      options: {library: library}
    ))
  end

  presets.keys.each do |label|
    define_singleton_method(:"#{label}_icon") do |**options|
      preset = presets.fetch(label)
      return icon(**options.merge(family: preset.family, variant: preset.variant))
    end
  end

  def self.define_icons(icon_definitions:)
    icon_definitions.each do |icon_definition|
      define_singleton_method(icon_definition.method_name) do
        preset = presets.fetch(icon_definition.preset.to_sym)
        return icon(
          family: preset.family,
          variant: preset.variant,
          name: icon_definition.icon_name
        )
      end
    end
  end

  def self.define_spritesheet_icons(spritesheet_icon_definitions:)
    spritesheet_icon_definitions.each do |icon_definition|
      define_singleton_method(icon_definition.method_name) do
        return spritesheet_icon(
          library: icon_definition.library,
          name: icon_definition.icon_name
        )
      end
    end
  end

  define_icons(icon_definitions: [
    IconDefinition.new(method_name: :user_icon, icon_name: :user, preset: :duotone),
    IconDefinition.new(method_name: :save_icon, icon_name: :"floppy-disk", preset: :duotone),
    IconDefinition.new(method_name: :filters_icon, icon_name: :filters, preset: :duotone),
    IconDefinition.new(method_name: :filters_icon, icon_name: :filters, preset: :duotone),
    IconDefinition.new(method_name: :ascending_icon, icon_name: :"sort-up", preset: :duotone),
    IconDefinition.new(method_name: :descending_icon, icon_name: :"sort-down", preset: :duotone),

    IconDefinition.new(method_name: :apply_filters_icon, icon_name: :filter, preset: :solid),
    IconDefinition.new(method_name: :generic_add_icon, icon_name: :"circle-plus", preset: :solid),
    IconDefinition.new(method_name: :error_list_icon, icon_name: :"circle-exclamation", preset: :solid),
    IconDefinition.new(method_name: :notes_icon, icon_name: :note, preset: :solid),
    IconDefinition.new(method_name: :dialog_close_icon, icon_name: :xmark, preset: :solid),

    IconDefinition.new(method_name: :sort_icon, icon_name: :sort, preset: :regular),

    IconDefinition.new(method_name: :info_icon, icon_name: :"circle-info", preset: :duotone),
    IconDefinition.new(method_name: :signup_icon, icon_name: :"user-plus", preset: :duotone),
    IconDefinition.new(method_name: :send_email_icon, icon_name: :"paper-plane", preset: :duotone),
    IconDefinition.new(method_name: :sent_email_icon, icon_name: :"envelope-dot", preset: :duotone),
    IconDefinition.new(method_name: :link_icon, icon_name: :link, preset: :duotone),
    IconDefinition.new(method_name: :remove_link_icon, icon_name: :"link-slash", preset: :duotone),
    IconDefinition.new(method_name: :theme_icon, icon_name: :swatchbook, preset: :duotone),
    IconDefinition.new(method_name: :sign_out_icon, icon_name: :"person-from-portal", preset: :duotone),
    IconDefinition.new(method_name: :theming_icon, icon_name: :"spray-can-sparkles", preset: :duotone),
    IconDefinition.new(method_name: :share_icon, icon_name: :"share-from-square", preset: :duotone),
    IconDefinition.new(method_name: :caution_diamond_icon, icon_name: :"diamond-exclamation", preset: :duotone),
    IconDefinition.new(method_name: :alert_icon, icon_name: :"triangle-exclamation", preset: :duotone),
    IconDefinition.new(method_name: :swap_icon, icon_name: :swap, preset: :duotone),
    IconDefinition.new(method_name: :waiting_icon, icon_name: :"hourglass-half", preset: :duotone),
    IconDefinition.new(method_name: :accept_icon, icon_name: :"circle-check", preset: :duotone),
    IconDefinition.new(method_name: :deny_icon, icon_name: :"circle-xmark", preset: :duotone),
    IconDefinition.new(method_name: :destroy_user_icon, icon_name: :"user-slash", preset: :duotone),
    IconDefinition.new(method_name: :organization_icon, icon_name: :warehouse, preset: :duotone),

    IconDefinition.new(method_name: :user_name_icon, icon_name: :"hand-wave", preset: :solid),
    IconDefinition.new(method_name: :email_address_icon, icon_name: :at, preset: :solid),
    IconDefinition.new(method_name: :light_theme_icon, icon_name: :sun, preset: :solid),
    IconDefinition.new(method_name: :dark_theme_icon, icon_name: :moon, preset: :solid),
    IconDefinition.new(method_name: :match_system_theme_icon, icon_name: :"circle-half-stroke", preset: :solid),
    IconDefinition.new(method_name: :previous_arrow, icon_name: :"arrow-left", preset: :solid),
    IconDefinition.new(method_name: :next_arrow, icon_name: :"arrow-right", preset: :solid),
    IconDefinition.new(method_name: :checkbox_check_icon, icon_name: :check, preset: :solid),
    IconDefinition.new(method_name: :passkey_label_icon, icon_name: :tag, preset: :solid),
    IconDefinition.new(method_name: :success_icon, icon_name: :"circle-check", preset: :solid),
    IconDefinition.new(method_name: :memberships_icon, icon_name: :hexagon, preset: :solid),
    IconDefinition.new(method_name: :badge_icon, icon_name: :"id-card", preset: :solid),
    IconDefinition.new(method_name: :close_toast_icon, icon_name: :"circle-xmark", preset: :solid),
    IconDefinition.new(method_name: :home_icon, icon_name: :home, preset: :solid),

    IconDefinition.new(method_name: :revoke_membership_invitation_icon, icon_name: :"link-slash", preset: :duotone),

    IconDefinition.new(method_name: :organization_manager_icon, icon_name: "users-gear", preset: :duotone),
  ])

  define_icons(icon_definitions: [
    IconDefinition.new(method_name: :csv_icon, icon_name: "file-csv", preset: :duotone),
    IconDefinition.new(method_name: :xls_icon, icon_name: "file-xls", preset: :duotone),
    IconDefinition.new(method_name: :doc_icon, icon_name: "file-doc", preset: :duotone),
    IconDefinition.new(method_name: :pdf_icon, icon_name: "file-pdf", preset: :duotone),
    IconDefinition.new(method_name: :heic_icon, icon_name: "file-image", preset: :duotone),
    IconDefinition.new(method_name: :missing_file_icon, icon_name: "file-slash", preset: :solid),
    IconDefinition.new(method_name: :txt_icon, icon_name: "file-txt", preset: :duotone),
  ])

  define_spritesheet_icons(spritesheet_icon_definitions: [
    SpritesheetIconDefinition.new(method_name: :passkey_icon, icon_name: :passkey, library: :kit),
    SpritesheetIconDefinition.new(method_name: :add_note_icon, icon_name: :"solid-note-circle-plus", library: :kit),
    SpritesheetIconDefinition.new(method_name: :edit_note_icon, icon_name: :"solid-note-pen", library: :kit),
    SpritesheetIconDefinition.new(method_name: :delete_note_icon, icon_name: :"solid-note-slash", library: :kit),
    SpritesheetIconDefinition.new(method_name: :archive_membership_icon, icon_name: :"solid-id-badge-slash",
                                  library: :kit),
    SpritesheetIconDefinition.new(method_name: :accepted_membership_invitation_icon,
                                  icon_name: :"solid-warehouse-circle-check", library: :kit),
    SpritesheetIconDefinition.new(method_name: :destroy_membership_invitation_icon,
                                  icon_name: :"solid-warehouse-slash", library: :kit),
    SpritesheetIconDefinition.new(method_name: :delete_note_icon, icon_name: :"solid-note-slash", library: :kit),

  ])

  def self.profile_icon = badge_icon

  def self.checkbox_indeterminate_icon
    solid_icon(name: :minus, options: {class: "indeterminate-icon"})
  end

  def self.emergency_passkey_registration_icon
    duotone_icon(name: :"light-emergency-on",
                 options: {style: "--secondary-color: var(--wa-color-danger-fill-loud); --secondary-opacity: 0.7;"})
  end

  def self.signin_icon
    duotone_icon(name: :"person-to-portal",
                 options: {style: "--secondary-color: var(--wa-color-brand-fill-normal); --secondary-opacity: 0.9;"})
  end

  def self.signout_icon
    duotone_icon(name: :"person-from-portal",
                 options: {style: "--secondary-color: var(--wa-color-brand-fill-normal); --secondary-opacity: 0.9;"})
  end
end