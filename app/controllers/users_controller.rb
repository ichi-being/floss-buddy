class UsersController < ApplicationController
  before_action :set_liff_id, only: [:new]
  before_action :login_required, only: [:show]
  require 'net/http'
  require 'uri'

  def new
    redirect_to after_login_path if current_user
  end

  def create
    user = authenticate_line_user(params[:idToken])
    session[:user_id] = user.id
    render json: user
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def show
    @user = current_user
    @floss_records = @user.floss_records.order(record_date: :desc)
  end

  private

  def authenticate_line_user(id_token)
    channel_id = ENV['LINE_LOGIN_CHANNEL_ID']
    res = Net::HTTP.post_form(URI.parse('https://api.line.me/oauth2/v2.1/verify'), { 'id_token' => id_token, 'client_id' => channel_id })
    raise "LINE API error: #{res.code}" unless res.is_a?(Net::HTTPSuccess)

    line_data = JSON.parse(res.body)
    line_user_id = line_data['sub']
    display_name = line_data['name']
    picture_url = line_data['picture']

    raise 'LINE user ID not found' unless line_user_id

    # ユーザーを検索、または新規作成し、情報を更新
    user = User.find_or_initialize_by(line_user_id: line_user_id)
    user.display_name = display_name.presence
    user.image = picture_url.presence
    user.save!

    user
  end
end
