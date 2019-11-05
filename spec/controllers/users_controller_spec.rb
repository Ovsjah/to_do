require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  include Signinable, Rememberable, SessionsHelper

  let!(:user) { create(:user) }
  let!(:new_user) { create(:user) }
  let!(:todo) { create(:todo, user: user) }
  let(:valid_params) { {user: attributes_for(:user)} }
  let(:invalid_params) { {user: attributes_for(:user).invert} }

  render_views

  describe 'GET #new' do
    it_behaves_like("it renders templates")
  end

  describe 'POST #create' do
    context "with valid params" do
      it "creates user" do
        expect {
          post :create, params: valid_params
        }.to change(User, :count).by(1)
      end
    end

    it_behaves_like("create action with invalid_params", User, :user)
  end

  describe 'GET #show' do
    it_behaves_like("default action", :show, :user)
    it_behaves_like("authorized action", :get, :show, :new_user)
  end

  describe 'GET #edit' do
    it_behaves_like("default action", :edit, :user)
    it_behaves_like("authorized action", :get, :edit, :new_user)
  end

  describe 'PATCH #update' do
    context "with valid params" do
      it_behaves_like("update of logged in/remembered", :sign_in,
                      :user, :name, user: {name: Faker::Name.name})
      it_behaves_like("update of logged in/remembered", :remember,
                      :user, :name, user: {name: Faker::Name.name})
      it_behaves_like("authorized action", :patch, :update, :new_user, user: {name: Faker::Name.name})
    end

    context "with invalid params" do
      let(:new_invalid_params) { {name: Faker::Name.name, email: ""}}

      before(:each) do
        sign_in(user)
        patch :update, params: {id: user.to_param, user: new_invalid_params}
      end

      it "doesn't update user" do
        expect(user.reload.name).not_to eq(new_invalid_params[:name])
      end

      it_behaves_like("has errors", :user)
    end
  end

  describe "DELETE #destroy" do
    it_behaves_like("action delete", User, :signup_path, :user)
    it_behaves_like("authorized action", :delete, :destroy, :new_user)
  end
end
