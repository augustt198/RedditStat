class UsersController < ApplicationController

  require 'json'

  def comments
    @username = params[:username]
    @about = user_about(@username)
    @comment_percentiles = user_comment_percentiles(@username)
    @data = @comment_percentiles[:data].to_json
    @title = @username
    @page = "comments"
  end

  def about
    @username = params[:username]
    @about = user_about @username
    @page = "about"
  end

  def user_search
    username = params[:user]
    if !user_exists?(username)
      flash[:danger] = "User not found"
      redirect_to '/'
    else

      redirect_to '/user/' + username
    end
  end

end