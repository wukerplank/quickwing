class ApplicationController < ActionController::Base
  protect_from_forgery

  def user_uuid
    session[:user_uuid] ||= SecureRandom.uuid
  end

  helper_method :user_uuid
end
