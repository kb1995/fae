module Fae
  class StaticPage < ActiveRecord::Base

    include Fae::StaticPageConcern
    include Fae::Concerns::Models::Base

    validates :title, presence: true

    @@has_assocs = false

    def self.instance
      set_assocs
      row = includes(fae_fields.keys).references(fae_fields.keys).find_by_slug(@slug)
      row = StaticPage.create(title: @slug.titleize, slug: @slug) if row.blank?
      row
    end

    def self.fae_fields
      {}
    end

  private

    def self.set_assocs
      return if @@has_assocs
      # create has_one associations from defined fae_fields
      fae_fields.each do |key, value|
        type = value.is_a?(Hash) ? value[:type] : value

        send :has_one, key.to_sym, -> { where(attached_as: key.to_s)}, as: poly_sym(type), class_name: type.to_s, dependent: :destroy
        send :accepts_nested_attributes_for, key, allow_destroy: true
        send :define_method, :"#{key}_content", -> { send(key.to_sym).try(:content) }

        if value.is_a?(Hash) && value[:validates].present?
          unique_method_name = "is_#{self.name.underscore}_#{key.to_s}?".to_sym
          slug = @slug
          value[:validates][:if] = unique_method_name
          type.validates(:content, value[:validates])
          type.send(:define_method, unique_method_name) do
            contentable.slug == slug && attached_as == key.to_s
          end
        end
      end
      @@has_assocs = true
    end

    def self.poly_sym(assoc)
      case assoc.name
      when 'Fae::TextField', 'Fae::TextArea'
        return :contentable
      when 'Fae::Image'
        return :imageable
      when 'Fae::File'
        return :fileable
      end
    end

  end
end
