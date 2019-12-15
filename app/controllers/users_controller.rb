class UsersController < ApplicationController
  include Signinable, SessionsHelper

  before_action :signed_in_user, :correct_user, except: %i[new create show]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      sign_in @user
      flash[:success] = "Congrats! You've logged in!"
      redirect_to @user
    else
      render :new
    end
  end

  def update
    if @user.update(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def show
    signed_in_user
    @user = User.includes(todos: :tasks).find(params[:id])
    correct_user
  end

  def destroy
    @user.destroy
    flash[:success] = "User deleted"
    redirect_to signup_path
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
