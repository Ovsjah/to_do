module Rememberable
  include ActiveSupport::Concern

  def remember(user)
    user.send(:remember)
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  def forget(user)
    user.send(:forget)
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  def remembered?
    cookies[:user_id].present? &&
      cookies[:remember_token].present?
  end
end
