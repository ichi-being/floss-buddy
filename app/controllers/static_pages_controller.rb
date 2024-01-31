class StaticPagesController < ApplicationController
  def top
    redirect_to profile_path if logged_in?
  end

  def contact; end

  def terms_of_service; end

  def privacy_policy; end
end
