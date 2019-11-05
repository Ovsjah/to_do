require 'rails_helper'

RSpec.describe TasksController, type: :controller do
  include Signinable, Rememberable, SessionsHelper

  let!(:user) { create(:user) }
  let!(:new_user) { create(:user) }
  let!(:todo) { create(:todo, user: user) }
  let!(:new_todo) { create(:todo, user: new_user) }
  let!(:task) { create(:task, todo: todo) }
  let!(:new_task) { create(:task, todo: new_todo) }
  let(:valid_params) { {task: attributes_for(:task), todo_id: todo.id} }
  let(:invalid_params) { {task: {description: ""}, todo_id: todo.id} }
  let(:params_without_todo) { {task: attributes_for(:task)} }

  render_views

  describe 'GET #new' do
    context "with logged in user" do
      before(:each) { sign_in(user) }

      it_behaves_like("it renders templates")
    end

    it_behaves_like("default action", :new)
    it_behaves_like("redirects user", :sign_in, :get, :new, :root_path, false, :todo)
    it_behaves_like("redirects user", :remember, :get, :new, :root_path, false, :todo)
  end

  describe 'POST #create' do
    context "with valid params" do
      context "with logged in user" do
        before(:each) { sign_in(user) }

        context "with valid params" do
          it "creates a task" do
            expect {
              post :create, params: valid_params
            }.to change(Task, :count).by(1)
          end
        end

        context "without todo id in params" do
          it "redirects to current_user" do
            post :create, params: params_without_todo
            expect(response).to redirect_to(current_user)
          end
        end
      end

      it_behaves_like("create action with invalid_params", Task, :task)
      it_behaves_like("redirects user", :sign_in, :post,
                      :create, :root_path, false,
                      :task, description: "Bye")
      it_behaves_like("redirects user", :remember, :post,
                      :create, :root_path, false,
                      :task, description: "Bye")
    end
  end

  describe 'GET #edit' do
    it_behaves_like("default action", :edit, :task)
    it_behaves_like("authorized action", :get, :edit, :new_task)
  end

  describe 'PATCH #update' do
    context "with valid params" do
      it_behaves_like("update of logged in/remembered", :sign_in,
                      :task, :description, task: {description: Faker::Name.name})
      it_behaves_like("update of logged in/remembered", :remember,
                      :task, :description, task: {description: Faker::Name.name})
      it_behaves_like("authorized action", :patch, :update, :new_task)
    end
  end

  describe "DELETE #destroy" do
    it_behaves_like("action delete", Task, :current_user, :user)
    it_behaves_like("authorized action", :delete, :destroy, :new_task)
  end
end
