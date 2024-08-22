# frozen_string_literal: true

RSpec.describe "User creation", type: :request do
  describe "valid user" do
    let(:user) { attributes_for(:user, email: "john.doe@email.com") }

    it "create user and redirect to user page" do
      get "/users/new"
      expect(response).to render_template(:new)

      post "/users", params: { user: user }, headers: {}
      expect(response).to redirect_to(assigns(:user))
      follow_redirect!

      expect(response).to render_template(:show)
      expect(response.body).to include("User was successfully created.")
    end
  end

  describe "invalid user" do
    let(:user) { attributes_for(:user, email: nil) }

    it "render user form and show error messages" do
      get "/users/new"
      expect(response).to render_template(:new)

      post "/users", params: { user: user }, headers: {}
      expect(response).to render_template(:new)
      expect(response.body).to include("Email can't be blank")
    end
  end
end
