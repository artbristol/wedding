# frozen_string_literal: true

require 'test_helper'

class SmtpWithSentCopyTest < ActiveSupport::TestCase
  class FakeImap
    attr_reader :calls

    def initialize
      @calls = []
    end

    def login(user, _password)
      @calls << [:login, user]
    end

    def append(folder, raw, _flags, _time)
      @calls << [:append, folder, raw]
    end

    def logout
      @calls << [:logout]
    end

    def disconnect; end
  end

  def delivery_method(imap_factory)
    DeliveryMethods::SmtpWithSentCopy.new(
      address: 'smtp.test', port: 587, user_name: 'user@example.com',
      password: 'secret', imap_host: 'imap.test', sent_folder: 'Sent',
      imap_factory: imap_factory
    )
  end

  test 'appends the raw message to the sent folder after delivery' do
    fake = FakeImap.new
    factory = ->(_host, **_opts) { fake }
    dm = delivery_method(factory)
    dm.send(:copy_to_sent_folder, 'RAW MESSAGE BODY')
    assert_includes fake.calls, [:login, 'user@example.com']
    assert_includes fake.calls, [:append, 'Sent', 'RAW MESSAGE BODY']
    assert_includes fake.calls, [:logout]
  end

  test 'skips the copy when imap host or folder is not configured' do
    factory = ->(*_a) { raise 'must not be called' }
    dm = DeliveryMethods::SmtpWithSentCopy.new(
      address: 'smtp.test', port: 587, user_name: 'u', password: 'p',
      imap_host: nil, sent_folder: nil, imap_factory: factory
    )
    assert_nothing_raised { dm.send(:copy_to_sent_folder, 'RAW') }
  end

  test 'a sent-folder failure does not raise (mail was already sent)' do
    factory = ->(*_a, **_kw) { raise 'imap down' }
    dm = delivery_method(factory)
    assert_nothing_raised { dm.send(:copy_to_sent_folder, 'RAW') }
  end
end
