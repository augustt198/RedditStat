class UsersController < ApplicationController

  def user
    render :json => JSON.pretty_generate(user_comment_percentiles(params[:username]))
    return
    @username = params[:username]
    @comments = user_comments(@username)
    @subreddits_count = Hash.new
    @about = user_about(@username)
    @comments.each do |c|
      if @subreddits_count[c["subreddit"]] == nil
        @subreddits_count[c["subreddit"]] = 1
      else
        @subreddits_count[c["subreddit"]] += 1
      end
    end
    render :json => JSON.pretty_generate({data: @comments})
  end

  def user_search
    username = params[:user]
    if !user_exists?(username)
      flash[:error] = "User not found"
      redirect_to '/'
    else

      redirect_to '/user/' + username
    end
  end

end