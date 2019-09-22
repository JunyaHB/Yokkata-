class UsersController < ApplicationController

  before_action :login_required, only: %i[edit]
  before_action :edit_limit, only: %i[edit]
  before_action :require_admin, only: %i[index]

  def new
    @user = User.new
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    user = User.find(params[:id])

    if params[:image]
      user.image_name = "#{user.id}.jpg"
      image = params[:image]
      File.binwrite("public/user_images/#{user.image_name}", image.read)
    end

    user.update!(user_params)
    redirect_to posts_url, notice: "プロフィールを編集しました。"
  end

  def create
    @user = User.new(user_params)
    @user.image_name = "default_user.png"

    if @user.save
      if params[:image]
        @user.image_name = "#{@user.id}.jpg"
        image = params[:image]
        File.binwrite("public/user_images/#{@user.image_name}", image.read)
      else
        @user.image_name = "default_user.png"
      end    
      @user.save
      session[:user_id] = @user.id
      redirect_to posts_url, notice: "ユーザー登録が完了しました。"
    else
      render :new
    end
  end

  def index
    @user = User.all
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :image_name)
  end

  def login_required
    redirect_to login_url, notice: "ログインをお願い致します。" unless current_user
  end

  #編集は、ユーザー自身のプロフィールのみとなるよう制限
  def edit_limit
    user = User.find(params[:id])
    redirect_to posts_url unless current_user.id == user.id
  end

#管理者のみアクセス可
  def require_admin
    redirect_to root_url unless current_user.admin?
  end


end