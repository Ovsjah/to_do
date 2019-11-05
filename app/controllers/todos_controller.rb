class TodosController < ApplicationController
  include SessionsHelper

  before_action :signed_in_user
  before_action :get_todo, :get_user, :correct_user, only: %i[edit update destroy]

  def new
    @todo = Todo.new
  end

  def create
    @todo = current_user.todos.new(todo_params)

    if @todo.save
      flash[:success] = "To Do list is added!"
      redirect_to current_user
    else
      render :new
    end
  end

  def update
    if @todo.update(todo_params)
      flash[:success] = "Todo title updated"
      redirect_to current_user
    else
      render :edit
    end
  end

  def destroy
    @todo.destroy
    flash[:success] = "Todo deleted"
    redirect_to current_user
  end

  private

  def todo_params
    params.require(:todo).permit(:title)
  end

  def get_todo
    @todo = Todo.find(params[:id])
  end

  def get_user
    @user = @todo.user
  end
end
