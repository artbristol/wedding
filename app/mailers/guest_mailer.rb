# frozen_string_literal: true

class GuestMailer < ApplicationMailer
  default from: ENV.fetch('FROM_EMAIL', nil),
          reply_to: ENV.fetch('CONTACT_EMAIL', nil)

  def confirmation_email(guest)
    @guest = guest
    mail(
      to: guest.name_with_email,
      subject: "#{I18n.t(:wedding_name)}: RSVP Confirmation"
    )
  end

  def welcome_back_email(guest)
    @guest = guest
    mail(
      to: guest.name_with_email,
      subject: "#{I18n.t(:wedding_name)}: Your RSVP"
    )
  end
end
