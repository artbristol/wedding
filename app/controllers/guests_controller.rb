# frozen_string_literal: true

require 'net/http'
require 'json'

class GuestsController < ApplicationController
  def new
    respond_to :html

    @guest = Guest.new
  end

  def create
    respond_to :html

    @guest = Guest.new(guest_params)
    unless turnstile_valid?
      @guest.errors.add(:base, 'Bitte bestätige, dass du kein Roboter bist.')
      render :new
      return
    end

    if @guest.save
      redirect_to guest_path(@guest)
    else
      existing_guest = Guest.find_by(email: guest_params[:email])
      if existing_guest
        @guest = existing_guest
        GuestMailer.welcome_back_email(@guest).deliver_now
        render :new_exists
      else
        render :new
      end
    end
  end

  def show
    respond_to :html

    @guest = Guest.find_by_id_token(params[:id])
  end

  def update
    @guest = Guest.find_by_id_token(params[:id])

    if @guest.update(guest_params)
      if @guest.attending?
        redirect_to guest_plus_ones_path(@guest)
      else
        redirect_to confirm_guest_path(@guest)
      end
    else
      render :show
    end
  end

  def confirm
    respond_to :html

    @guest = Guest.find_by_id_token(params[:id])
  end

  def complete
    respond_to :html

    @guest = Guest.find_by_id_token(params[:id])
    Guest.transaction do
      @guest.update!(guest_params)
      @guest.touch :confirmed_at
    end
    GuestMailer.confirmation_email(@guest).deliver_now
  end

  private

  # Cloudflare Turnstile server-side verification. Skipped entirely when no
  # secret key is configured (local/test environments, pre-launch deploys).
  # Fail closed: any network or parse problem rejects the submission.
  def turnstile_valid?
    return true if ENV.fetch('TURNSTILE_SECRET_KEY', nil).blank?

    token = params['cf-turnstile-response']
    return false if token.blank? || token.length > 2048

    result = verify_with_cloudflare(token)
    result['success'] == true &&
      result['action'] == 'rsvp' &&
      turnstile_hostnames.include?(result['hostname'])
  rescue StandardError
    false
  end

  def verify_with_cloudflare(token)
    uri = URI('https://challenges.cloudflare.com/turnstile/v0/siteverify')
    body = URI.encode_www_form(
      secret: ENV.fetch('TURNSTILE_SECRET_KEY', nil),
      response: token,
      remoteip: request.remote_ip
    )
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 10
    http.read_timeout = 10
    response = http.post(uri.request_uri, body,
                         'Content-Type' => 'application/x-www-form-urlencoded')
    JSON.parse(response.body)
  end

  def turnstile_hostnames
    (ENV.fetch('TURNSTILE_HOSTNAMES', nil) || 'example-site.example')
      .split(',').map(&:strip).reject(&:blank?)
  end

  def guest_params
    params.require(:guest).permit(
      :email, :first_name, :last_name, :attending, :diet, :songs, :notes
    )
  end
end
