# frozen_string_literal: true

require 'application_system_test_case'

class RsvpHappyPathTest < ApplicationSystemTestCase
  test 'RSVP attending' do
    visit root_url
    click_link 'Jetzt RSVP senden!', match: :first

    fill_in 'E-Mail', with: 'test@example.com'
    click_on 'Weiter'

    #
    # About You
    #
    fill_in 'Vorname', with: 'Test'
    fill_in 'Nachname', with: 'User'
    choose 'Ja'
    fill_in 'Essenswünsche', with: 'Level 5 Vegan'
    fill_in 'Songwünsche', with: 'Mozart'
    click_on 'Weiter'

    #
    # Plus Ones
    #
    click_on 'Begleitung hinzufügen'

    fill_in 'Vorname', with: 'Test Plus'
    fill_in 'Nachname', with: 'One Name'
    fill_in 'Essenswünsche', with: 'Vegetarian'
    check 'Kind (12 Jahre oder jünger)'
    click_on 'Begleitung hinzufügen'

    assert page.has_content? 'Test Plus One Name'

    click_on 'Begleitung hinzufügen'

    fill_in 'Vorname', with: 'Test Plus'
    fill_in 'Nachname', with: 'Two Name'
    fill_in 'Essenswünsche', with: 'Pescatarian'
    check 'Kind (12 Jahre oder jünger)'
    click_on 'Begleitung hinzufügen'

    assert page.has_content? 'Test Plus One Name'
    assert page.has_content? 'Test Plus Two Name'

    click_on 'Weiter'

    #
    # Confirm
    #

    assert page.has_content? 'Test User'
    assert page.has_content? 'Level 5 Vegan'
    assert page.has_content? 'Mozart'
    assert page.has_content? 'Test Plus One Name'
    assert page.has_content? 'Vegetarian'
    assert page.has_content? 'Test Plus Two Name'
    assert page.has_content? 'Pescatarian'

    fill_in 'guest[notes]', with: 'I hope there is cake!'

    click_on 'RSVP abschicken'

    assert_equal 1, ActionMailer::Base.deliveries.size
    email = ActionMailer::Base.deliveries.last
    assert_equal 'test@example.com', email.to[0]
  end

  test 'RSVP not attending' do
    visit root_url
    click_link 'Jetzt RSVP senden!', match: :first

    fill_in 'E-Mail', with: 'test@example.com'
    click_on 'Weiter'

    #
    # About You
    #
    fill_in 'Vorname', with: 'Test'
    fill_in 'Nachname', with: 'User'
    choose 'Nein'

    click_on 'Weiter'

    #
    # Skip to Confirm
    #
    assert page.has_content? 'Test User'
    assert page.has_content? 'Schade, dass du nicht dabei'

    click_on 'RSVP abschicken'

    assert_equal 1, ActionMailer::Base.deliveries.size
    email = ActionMailer::Base.deliveries.last
    assert_equal 'test@example.com', email.to[0]
  end

  test 'Sends RSVP update email' do
    visit root_url
    click_link 'Jetzt RSVP senden!', match: :first

    fill_in 'E-Mail', with: 'test@example.com'
    click_on 'Weiter'

    fill_in 'Vorname', with: 'Test'
    fill_in 'Nachname', with: 'User'

    click_on 'Weiter'
    click_on 'Weiter' # No plus ones
    click_on 'RSVP abschicken'

    assert_equal 1, ActionMailer::Base.deliveries.size

    visit root_url
    click_link 'Jetzt RSVP senden!', match: :first

    fill_in 'E-Mail', with: 'test@example.com'
    click_on 'Weiter'

    assert page.has_content? 'Willkommen zurück'

    assert_equal 2, ActionMailer::Base.deliveries.size
    email = ActionMailer::Base.deliveries.last
    assert_equal 'test@example.com', email.to[0]
  end
end
