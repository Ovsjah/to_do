require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  include Signinable, Rememberable, SessionsHelper

  let(:user) { create(:user) }
  render_views

  describe "GET #new" do
    it "renders new view" do
      get :new
      expect(response).to render_template('new')
    end
  end

  describe 'POST #create' do
    let(:valid_params) { {email: user.email, password: user.password} }
    let(:with_remembering) { valid_params.merge(remember_me: '1') }
    let(:invalid_params) { {email: '', password: ''} }

    context "with valid params" do
      before(:each) { post :create, params: {session: valid_params} }

      it "stores the user_id in session" do
        expect(session[:user_id]).to be_present
      end

      it "logs in a user" do
        expect(signed_in?).to be true
      end

      it "redirects to the show view" do
        expect(response).to redirect_to user
      end
    end

    context "with remembering" do
      before(:each) { post :create, params: {session: with_remembering} }

      it "stores the user's id in cookies" do
        expect(cookies[:user_id]).to be_present
      end

      it "stores the user's remember token in cookies" do
        expect(cookies[:remember_token]).to be_present
      end

      it "remembers a user" do
        expect(remembered?).to be true
      end
    end

    context "with invalid params" do
      before(:each) { post :create, params: {session: invalid_params} }

      it "has a message inside the flash hash" do
        expect(flash).to be_present
      end

      it "renders the new view" do
        expect(response).to render_template('new')
      end
    end

    describe 'DELETE #destroy' do
      context "with logging in" do
        before(:each) do
          sign_in user
          delete :destroy, params: {id: user.to_param}
        end

        it "deletes the user's session" do
          expect(session).to be_empty
        end

        it "redirects to root" do
          expect(response).to redirect_to(root_path)
        end
      end

      context "with remembering" do
        before(:each) do
          remember user
          delete :destroy, params: {id: user.to_param}
          cookies.update(response.cookies)
        end

        it "deletes the user's id from cookies" do
          expect(cookies[:user_id]).to be_nil
        end

        it "deletes the user's remember token form cookies" do
          expect(cookies[:remember_token]).to be_nil
        end
      end
    end
  end
end
