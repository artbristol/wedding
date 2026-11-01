# frozen_string_literal: true

require 'test_helper'

class GuestsControllerTest < ActionDispatch::IntegrationTest
  test 'checks for duplicates on email update' do
    guest_one = guests(:one)
    guest_two = guests(:two)

    patch guest_path(guest_one), params: {
      guest: { email: guest_two.email }
    }

    assert_select 'li', 'Diese E-Mail-Adresse ist bereits registriert'
  end

  test 'records confirmed_at time' do
    guest_one = guests(:one)

    patch complete_guest_path(guest_one), params: { guest: { notes: '' } }

    guest_one.reload
    assert guest_one.confirmed_at
  end
end

class GuestsControllerTurnstileTest < ActionDispatch::IntegrationTest
  test 'rejects submission without token when turnstile is configured' do
    ENV['TURNSTILE_SECRET_KEY'] = 'test-secret'
    begin
      assert_no_difference 'Guest.count' do
        post guests_path, params: { guest: { email: 'bot@example.com' } }
      end
      assert_response :success
      assert_select 'li', 'Bitte bestätige, dass du kein Roboter bist.'
    ensure
      ENV['TURNSTILE_SECRET_KEY'] = nil
    end
  end

  test 'skips verification when turnstile is not configured' do
    assert ENV['TURNSTILE_SECRET_KEY'].blank?
    assert_difference 'Guest.count', 1 do
      post guests_path,
           params: { guest: { email: 'human@example.com', first_name: 'A',
                              last_name: 'B' } }
    end
  end
end
