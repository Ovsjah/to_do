shared_examples "has errors" do |model|
  it "renders full error messages" do
    assigns(model).errors.full_messages.each do |msg|
      expect(response.body).to have_text(msg)
    end
  end
end

shared_examples "create action with invalid_params" do |class_name, model|
  before(:each) do
    sign_in(user)
    post :create, params: invalid_params
  end

  it "doesn't create a user" do
    expect {
      post :create, params: invalid_params
    }.not_to change(class_name, :count)
  end

  it "renders the new template" do
    post :create, params: invalid_params
    expect(response).to render_template('new')
  end

  it_behaves_like("has errors", model)
end

shared_examples "it renders templates" do
  before(:each) { get :new, params: fuse(id: nil) }

  it "renders the new template" do
    expect(response).to render_template('new')
  end

  it "renders the form partial" do
    expect(response).to render_template(partial: "shared/_form")
  end

  it "renders the error_messages partial" do
    expect(response).to render_template(partial: "shared/_error_messages")
  end
end

shared_examples "action delete" do |class_name, path, model|
  context "with logged in user" do
    before(:each) { sign_in(user) }

    it "destroys the requested #{model}" do
      expect {
        delete :destroy, params: {id: to_params(model)}
      }.to change(class_name, :count).by(-1)
    end

    it "redirects to sign up" do
      delete :destroy, params: {id: to_params(model)}
      expect(response).to redirect_to(send(path))
    end
  end
end

shared_examples "with logged in/remembered user" do |*args|
  method_name, action, model = args
  it "renders the #{action} view if #{edit(method_name)}" do
    send(method_name, user)
    get action, params: fuse({id: to_params(model)})

    expect(response).to render_template(action)
  end
end

shared_examples "update of logged in/remembered" do |method_name, model, attr, new_params|
  it "updates the #{edit(method_name)} user's #{model}" do
    send(method_name, user)
    patch :update, params: {id: to_params(model)}.merge(new_params)

    expect(send(model).reload.send(attr)).to eq(new_params[model][attr])
  end
end

shared_examples "redirects user" do |*args|
  method_name, verb, action, path, session_status, model, new_params = args
  it "redirects to the #{path} #{full_edit(method_name, session_status)}" do
    send(method_name, user) if session_status
    create(:task, todo: create(:todo, user: new_user))
    send(verb, action, params: fuse({id: to_params(model)}, new_params))

    expect(subject).to redirect_to(send(path))
  end

  unless session_status
    it "has the flash error" do
      get action, params: {id: create(:user).to_param}

      expect(flash).to be_present
    end
  end
end

shared_examples "default action" do |*args|
  action, model, params = *args
  it_behaves_like("with logged in/remembered user", :sign_in, action, model, params)
  it_behaves_like("with logged in/remembered user", :remember, action, model, params)
end

shared_examples "authorized action" do |verb, action, model|
  it_behaves_like("redirects user", :sign_in, verb, action, :current_user, true, model)
  it_behaves_like("redirects user", :remember, verb, action, :current_user, true, model)
  it_behaves_like("redirects user", :sign_in, verb, action, :root_path, false, model)
  it_behaves_like("redirects user", :remember, verb, action, :root_path, false, model)
end

def to_params(model)
  send(model).to_param if model
end

def fuse(params, new_params = {todo_id: to_params(:todo)})
  new_params ? params.merge(new_params) : params
end

def edit(method_name)
  method_name == :sign_in ? "logged in" : "#{method_name}ed"
end

def full_edit(method_name, session_status)
  session_status ? "if #{edit(method_name)} user is incorrect" : "if not #{edit(method_name)}"
end
