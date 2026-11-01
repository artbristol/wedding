# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('FROM_EMAIL', 'webmaster@localhost'),
          reply_to: ENV.fetch('CONTACT_EMAIL', nil)
  layout 'mailer'
end
