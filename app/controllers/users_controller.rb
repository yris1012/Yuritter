class UsersController < ApplicationController

  #application_controllerで定義したメソッド
  before_action :authenticate_user, {only: [:index, :show, :edit, :update]}
  before_action :forbid_login_user, {only: [:new, :create, :login_form, :login]}
  #このファイルで定義したメソッド
  before_action :ensure_correct_user, {only: [:edit, :update]}

  def index
    @users=User.all.order(created_at: :desc)
  end

  def show
    @user=User.find(params[:id])
    #@user=User.find_by(id: params[:id])
    @posts_count=Post.where(user_id: @user.id).count
    @likes_count=Like.where(user_id: @user.id).count
    #@following_count=@user.following.count
    #@followers_count=@user.followers.count
  end

  def new
    @user=User.new
  end

  def create
    @user=User.new(user_params) #privateメソッド(下で定義)
    @user.image_name= "kari_icon.jpg"
    # @user=User.new(params[:user])
      #paramsハッシュをまるごと渡す(全体を初期化する)のはセキュリティ上危険なためRailsはデフォルトでエラーを返す
    # @user=User.new(
    #   name: params[:name],
    #   email: params[:email],
    #   image_name: "kari_icon.jpg",
    #   password: params[:password])
    if @user.save
      log_in @user
      #session[:user_id]=@user.id
      flash[:notice]="Welcome to Yuritter!"
      redirect_to @user
      #redirect_to user_url(@user) #と等価
      #redirect_to("/users/#{@user.id}")
    else
      render 'new'
      #render("users/new")
    end
  end

  def edit
    @user=User.find(params[:id])
  end

  # def update
  #   if @user.update_attributes(user_params)
  #     flash[:success] = "Profile updated"
  #     redirect_to @user
  #   else
  #     render 'edit'
  #   end
  # end
  
  # def update
  #   @user=User.find_by(id: params[:id])
  #   @user.update_attributes(
  #     name: params[:name],
  #     email: params[:email]
  #   )
  #   if params[:image]
  #     @user.update_attributes(image_name: "#{@user.id}.jpg")
  #     image=params[:image]
  #     File.binwrite("public/user_images/#{@user.image_name}", image.read)
  #   end
  #
  #   if @user.save
  #     flash[:notice]="edited!"
  #     redirect_to("/users/#{@user.id}")
  #   else
  #     render("users/edit")
  #   end
  #
  # end

  def update
    @user=User.find_by(id: params[:id])
    @user.name=params[:name]
    @user.email=params[:email]
    if params[:image]
      @user.image_name="#{@user.id}.jpg"
      image=params[:image]
      File.binwrite("public/user_images/#{@user.image_name}", image.read)
    end
    if @user.save
      flash[:notice]="edited!"
      redirect_to("/users/#{@user.id}")
    else
      render("users/edit")
    end
  end

  #sessionsのnewアクションに移行
  # def login_form
  # end

  #sessionsのcreateアクションに移行
  # def login
  #   @user=User.find_by(email: params[:email])
  #   if @user && @user.authenticate(params[:password])
  #     session[:user_id]=@user.id
  #     flash[:notice]="login successfully"
  #     redirect_to("/posts/index")
  #   else
  #     @error_message="Invalid login, please try again."
  #     @email=params[:email]
  #     @password=params[:password]
  #     render("users/login_form")
  #   end
  # end

  #sessionsのdestroyアクションに移行
  # def logout
  #   session[:user_id]=nil
  #   flash[:notice]="logout successfully"
  #   redirect_to("/login")
  # end

  def likes
    @user=User.find_by(id: params[:id])
    @likes=Like.where(user_id: @user.id)
    @posts_count=Post.where(user_id: @user.id).count
    @likes_count=Like.where(user_id: @user.id).count
    #@following_count=@user.following.count
    #@followers_count=@user.followers.count
  end

  def following
    @user=User.find(params[:id])
    @users=@user.following
    @posts_count=Post.where(user_id: @user.id).count
    @likes_count=Like.where(user_id: @user.id).count
    #@following_count=@user.following.count
    #@followers_count=@user.followers.count
  end

  def followers
    @user=User.find(params[:id])
    @users=@user.followers
    @posts_count=Post.where(user_id: @user.id).count
    @likes_count=Like.where(user_id: @user.id).count
    #@following_count=@user.following.count
    #@followers_count=@user.followers.count
  end



  def ensure_correct_user
    if @current_user.id != params[:id].to_i
      flash[:notice]="You don't have permisson to access."
      redirect_to("/posts/index")
    end
  end


 private
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

end
