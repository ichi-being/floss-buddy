class UsersController < ApplicationController
  before_action :set_liff_id, only: [:new]
  require 'net/http'
  require 'uri'

  def new
    if current_user
      redirect_to after_login_path
    end
  end

  def create
    user = authenticate_line_user(params[:idToken])
    session[:user_id] = user.id
    render json: user
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def authenticate_line_user(id_token)
    channel_id = ENV['LINE_LOGIN_CHANNEL_ID']
    res = Net::HTTP.post_form(URI.parse('https://api.line.me/oauth2/v2.1/verify'), { 'id_token' => id_token, 'client_id' => channel_id })
    raise "LINE API error: #{res.code}" unless res.is_a?(Net::HTTPSuccess)

    line_user_id = JSON.parse(res.body)['sub']
    raise 'LINE user ID not found' unless line_user_id
    User.find_or_create_by(line_user_id: line_user_id)
  end
end
