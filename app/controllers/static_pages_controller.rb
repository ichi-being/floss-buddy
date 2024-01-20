class StaticPagesController < ApplicationController
  def top
    render logged_in? ? :after_login : :before_login
  end

  def after_login
    login_required
    @current_user = User.find(session[:user_id]) if session[:user_id]
  end

  def before_login; end

  def contact; end

  def terms_of_service; end

  def privacy_policy; end
end
