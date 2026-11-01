# frozen_string_literal: true

require 'test_helper'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # driven_by :selenium, using: :chrome, screen_size: [1400, 1400]
  driven_by :rack_test

  # System tests assert absolute delivery counts; unlike mailer test cases,
  # they do not clear ActionMailer::Base.deliveries automatically.
  setup do
    ActionMailer::Base.deliveries.clear
  end
end
