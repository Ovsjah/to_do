require 'rails_helper'

RSpec.describe TodosController, type: :controller do
  include Signinable, Rememberable, SessionsHelper

  let!(:user) { create(:user) }
  let!(:new_user) { create(:user) }
  let!(:todo) { create(:todo, user: user) }
  let!(:new_todo) { create(:todo, user: new_user) }
  let(:valid_params) { {todo: attributes_for(:todo, user: user)} }
  let(:invalid_params) { {todo: {title: "", user: user}} }

  render_views

  describe 'GET #new' do
    context "with logged in user" do
      before(:each) { sign_in(user) }

      it_behaves_like("it renders templates")
    end

    it_behaves_like("default action", :new)
    it_behaves_like("redirects user", :sign_in, :get, :new, :root_path, false)
    it_behaves_like("redirects user", :remember, :get, :new, :root_path, false)
  end

  describe 'POST #create' do
    context "with valid params" do
      context "with logged in user" do
        before(:each) { sign_in(user) }

        it "creates a todo" do
          expect {
            post :create, params: valid_params
          }.to change(Todo, :count).by(1)
        end
      end

      it_behaves_like("redirects user", :sign_in, :post,
                      :create, :root_path, false,
                      :todo, {title: Faker::Book.title})
      it_behaves_like("redirects user", :remember, :post,
                      :create, :root_path, false,
                      :todo, {title: Faker::Book.title})
    end

    it_behaves_like("create action with invalid_params", Todo, :todo)
  end

  describe 'GET #edit' do
    it_behaves_like("default action", :edit, :todo)
    it_behaves_like("authorized action", :get, :edit, :new_todo)
  end

  describe 'PATCH #update' do
    context "with valid params" do
      it_behaves_like("update of logged in/remembered", :sign_in,
                      :todo, :title, todo: {title: Faker::Book.title})
      it_behaves_like("update of logged in/remembered", :remember,
                      :todo, :title, todo: {title: Faker::Book.title})
      it_behaves_like("authorized action", :patch, :update, :new_todo)
    end
  end

  describe "DELETE #destroy" do
    it_behaves_like("action delete", Todo, :current_user, :user)
    it_behaves_like("authorized action", :delete, :destroy, :new_todo)
  end
end
