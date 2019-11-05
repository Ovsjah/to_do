class TasksController < ApplicationController
  include SessionsHelper

  before_action :signed_in_user
  before_action :to_current_user, only: %i[new create]
  before_action :get_todo, only: %i[new create]
  before_action :get_task, :get_user, :correct_user, only: %i[edit update destroy]

  def new
    @task = Task.new
  end

  def create
    @task = @todo.tasks.new(task_params)

    if @task.save
      flash[:success] = "Task is added!"
      redirect_to current_user
    else
      render :new
    end
  end

  def update
    if @task.update(task_params)
      flash[:success] = "Task updataed"
      redirect_to current_user
    else
      render :edit
    end
  end

  def destroy
    @task.destroy
    flash[:success] = "Task deleted"
    redirect_to current_user
  end

  private

  def task_params
    params.require(:task).permit(:description)
  end

  def get_todo
    @todo = Todo.find(params[:todo_id])
  end

  def get_task
    @task = Task.find(params[:id])
  end

  def get_user
    @user = @task.todo.user
  end

  def to_current_user
    redirect_to current_user if signed_in? && no_todo_id?
  end

  def no_todo_id?
    params[:todo_id].nil?
  end
end
