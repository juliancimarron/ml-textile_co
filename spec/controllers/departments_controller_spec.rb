require 'rails_helper'
require 'support/model_attributes'

RSpec.describe DepartmentsController, type: :controller do
  # include_context 'model_attributes'

  # fixtures :departments

  # let(:dept) { departments(:sales) }

  # describe "GET #index" do
  #   it "assigns all departments as @departments" do
  #     get :index
  #     expect(assigns(:departments)).to eq(Department.all)
  #   end
  # end

  # describe "GET #show" do
  #   it "assigns the requested department as @department" do
  #     get :show, {:id => dept.id}
  #     expect(assigns(:department)).to eq(dept)
  #   end
  # end

  # describe "GET #new" do
  #   it "assigns a new department as @department" do
  #     get :new
  #     expect(assigns(:department)).to be_a_new(Department)
  #   end
  # end

  # describe "GET #edit" do
  #   it "assigns the requested department as @department" do
  #     get :edit, {:id => dept.id}
  #     expect(assigns(:department)).to eq(dept)
  #   end
  # end

  # describe "POST #create" do
  #   context "with valid params" do
  #     it "creates a new Department" do
  #       expect {
  #         post :create, {:department => department_valid_attributes}
  #       }.to change(Department, :count).by(1)
  #     end

  #     it "assigns a newly created department as @department" do
  #       post :create, {:department => department_valid_attributes}
  #       expect(assigns(:department)).to be_a(Department)
  #       expect(assigns(:department)).to be_persisted
  #     end

  #     it "redirects to the created department" do
  #       post :create, {:department => department_valid_attributes}
  #       expect(response).to redirect_to(Department.last)
  #     end
  #   end

  #   context "with invalid params" do
  #     it "assigns a newly created but unsaved department as @department" do
  #       post :create, {:department => department_invalid_attributes}
  #       expect(assigns(:department)).to be_a_new(Department)
  #     end

  #     it "re-renders the 'new' template" do
  #       post :create, {:department => department_invalid_attributes}
  #       expect(response).to render_template("new")
  #     end
  #   end
  # end

  # describe "PUT #update" do
  #   context "with valid params" do
  #     let(:new_attributes) { {name: 'Updated Dept Name'} }

  #     it "updates the requested department" do
  #       put :update, {:id => dept.id, :department => new_attributes}
  #       dept.reload
  #       expect(dept.name).to eq new_attributes[:name]
  #     end

  #     it "assigns the requested department as @department" do
  #       put :update, {:id => dept.id, :department => department_valid_attributes}
  #       expect(assigns(:department)).to eq(dept)
  #     end

  #     it "redirects to the department" do
  #       put :update, {:id => dept.id, :department => department_valid_attributes}
  #       expect(response).to redirect_to(dept)
  #     end
  #   end

  #   context "with invalid params" do
  #     it "assigns the department as @department" do
  #       put :update, {:id => dept.id, :department => department_invalid_attributes}
  #       expect(assigns(:department)).to eq(dept)
  #     end

  #     it "re-renders the 'edit' template" do
  #       put :update, {:id => dept.id, :department => department_invalid_attributes}
  #       expect(response).to render_template("edit")
  #     end
  #   end
  # end

  # describe "DELETE #destroy" do
  #   it "destroys the requested department" do
  #     expect {
  #       delete :destroy, {:id => dept.id}
  #     }.to change(Department, :count).by(-1)
  #   end

  #   it "redirects to the departments list" do
  #     delete :destroy, {:id => dept.id}
  #     expect(response).to redirect_to(departments_url)
  #   end
  # end

end
