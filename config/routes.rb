RedditStat::Application.routes.draw do

  root 'index#home'

  match 'user/:username/comments' => 'users#comments', via: [:get]
  match 'user/:username' => 'users#about', via: [:get]
  match 'user_search' => 'users#user_search', via: [:get]

  # JSON
  match 'json/:username' => 'json#user', via: [:get]

end
