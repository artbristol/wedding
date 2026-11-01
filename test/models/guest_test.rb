# frozen_string_literal: true

require 'test_helper'

class GuestTest < ActiveSupport::TestCase
  test 'email_safe_salutation' do
    guest = guests(:one)
    assert_equal 'Hallo Guest,', guest.email_safe_salutation
    guest.first_name = 'Visit spam.com'
    assert_equal 'Hallo,', guest.email_safe_salutation
    guest.first_name = 'Visit spam dot com for free stuff' # too long
    assert_equal 'Hallo,', guest.email_safe_salutation
  end
end
