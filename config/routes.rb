RedditStat::Application.routes.draw do

  root 'index#home'

  match 'user/:username/comments' => 'users#comments', via: [:get]
  match 'user/:username' => 'users#about', via: [:get]
  match 'user_search' => 'users#user_search', via: [:get]

  # JSON
  match 'json/comment_percentile/:username' => 'json#comment_percentiles', via: [:get]

end
