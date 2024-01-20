class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?, :login_required

  private

  def current_user
    # @current_userがnilでsession[:user_id]に値が入っている場合、ユーザーを持ってくる
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def login_required
    # 未ログインの場合（current_userが存在しない場合）root_pathに飛ばす
    redirect_to root_path unless current_user
  end

  def logged_in?
    current_user.present?
  end

  def set_liff_id
    gon.liff_id = ENV['LIFF_ID']
  end
end
