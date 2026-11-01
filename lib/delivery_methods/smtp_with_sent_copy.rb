# frozen_string_literal: true

module DeliveryMethods
  # SMTP delivery that also appends the sent message to an IMAP "Sent"
  # folder, so outgoing site mail shows up in webmail.
  #
  # Deliberately NOT a Mail::SMTP subclass: the mail gem is only loaded
  # during eager_load, so Mail must not be referenced when this file is
  # required during boot. The SMTP work is delegated at delivery time.
  #
  # SMTP failures raise as usual (mail not sent); Sent-folder failures are
  # logged and swallowed (mail was already sent, so delivery must not fail
  # afterwards).
  class SmtpWithSentCopy
    def initialize(settings)
      @settings = settings
    end

    def deliver!(mail)
      ::Mail::SMTP.new(@settings).deliver!(mail)
      copy_to_sent_folder(mail.to_s)
    end

    private

    def copy_to_sent_folder(raw)
      imap_host = @settings[:imap_host]
      folder = @settings[:sent_folder]
      if imap_host.blank? || folder.blank?
        Rails.logger.warn('Sent-folder copy skipped: ' \
                          'IMAP_HOST/IMAP_SENT_FOLDER not configured')
        return
      end

      factory = @settings[:imap_factory]
      imap = if factory
               factory.call(imap_host,
                            ssl: true)
             else
               Net::IMAP.new(imap_host,
                             ssl: true)
             end
      begin
        imap.login(@settings[:user_name], @settings[:password])
        imap.append(folder, raw, nil, Time.now)
      ensure
        begin
          imap.logout
        rescue StandardError
          nil
        end
        begin
          imap.disconnect
        rescue StandardError
          nil
        end
      end
    rescue StandardError => e
      Rails.logger.warn("Sent-folder copy failed: #{e.class}: #{e.message}")
    end
  end
end
