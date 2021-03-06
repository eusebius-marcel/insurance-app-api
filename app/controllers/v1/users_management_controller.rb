class V1::UsersManagementController < ApplicationController
  before_action :authenticate_admin
  attr_reader :old_email

  def index
    users = User.all.order(:id)
    users = users.users_by_product(params[:insurance_type]) if params[:insurance_type].present?
    users = users.search_name(params[:name]) if params[:name].present?
    users = users.search_email(params[:email]) if params[:email].present?
    users_per_page = users.paginate(page: params[:page])
    render json: { status: 'OK', total_users: users.count, users: users_per_page }, status: :ok
  end

  def create_by_csv
    User.import!(params[:file])
    render json: { created_users: User.created_users,
        failed_to_create_users: User.failed_to_create_users }, status: :ok
  end

  def update
    user = User.find(params[:id])
    @old_email = user.email
    user.update!(update_user_params)
    send_new_password_to_new_email(user) unless params[:email].blank?
    render json: { status: "User berhasil diupdate", result: user.as_json(except:
        %i[password_digest reset_password_token reset_password_token_sent_at]) },
          status: :ok
  end

  private

  def update_user_params
    params.permit(:email, :address, :phone_number)
  end

  def send_new_password_to_new_email(user)
    return if user.email == old_email
    user.password = user.generate_token
    user.save!
    UserMailer.with(user: user).change_email.deliver
  end
end