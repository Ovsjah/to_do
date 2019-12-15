module SessionsHelper
  def current_user?(user)
    user == current_user
  end

  def current_user
    @current_user ||=
      if (user_id = session[:user_id])
        User.find_by_id(user_id)
      elsif (user_id = cookies.signed[:user_id])
        user = User.find_by_id(user_id)
        user if user&.authenticated?(:remember, cookies[:remember_token])
      end
  end

  def signed_in?
    !!current_user
  end

  def signed_in_user
    unless signed_in?
      flash[:danger] = "Restricted for non members"
      redirect_to root_path
    end
  end

  def correct_user
    @user ||= User.find(params[:id])
    redirect_to current_user unless current_user? @user
  end
end
