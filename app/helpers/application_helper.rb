# frozen_string_literal: true

module ApplicationHelper
  FLASH_CLASSES = {
    notice: 'alert alert-info',
    success: 'alert alert-success',
    error: 'alert alert-error',
    alert: 'alert alert-error'
  }.freeze

  def flash_class(key)
    FLASH_CLASSES[key]
  end

  def errors_for(object)
    return unless object.errors.any?

    content_tag(:div, class: 'mb-3 card border-danger') do
      concat(content_tag(:div, class: 'card-header bg-danger text-white') do
        count = object.errors.count
        problems = count == 1 ? 'ein Problem' : "#{count} Probleme"
        concat "Hoppla, #{problems}:"
      end)
      concat(content_tag(:ul, class: 'mb-0 list-group list-group-flush') do
        object.errors.full_messages.each do |msg|
          concat content_tag(:li, msg, class: 'list-group-item')
        end
      end)
    end
  end
end
