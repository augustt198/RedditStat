def user_comments_long(username)
  base = "http://www.reddit.com/user/" + username + '/comments.json?limit=1000'
  opts = ""
  comments = []
  count = 0
  while true do
    data = Net::HTTP.get_response(URI.parse(base + opts)).body
    json = JSON.parse(data)
    if json["error"] == 404
      return comments
    end
    json["data"]["children"].each do |comment|
      comments << comment["data"]
    end
    if json["data"]["after"] != nil
      opts = "&after=" + json["data"]["after"]
    else
      break
    end
  end
  return comments
end

def user_about(username)
  base = "http://www.reddit.com/user/" + username +'/about.json'
  data = Net::HTTP.get_response(URI.parse(base)).body
  json = JSON.parse(data)
  return json["data"]
end

def user_submitted(username)
  base = "http://www.reddit.com/user/" + username + '/submitted.json'
  opts = ""
  submits = []
  while true do
    data = Net::HTTP.get_response(URI.parse(base + opts)).body
    json = JSON.parse(data)
    json["data"]["children"].each do |post|
      submits << post["data"]
    end
    if json["data"]["after"] != "null"
      opts = "?after=" + json["data"]["after"]
    else
      break
    end
  end
  return submits
end

def user_exists?(username)
  url = "http://www.reddit.com/user/" + username + ".json"
  data = Net::HTTP.get_response(URI.parse(url)).body
  json = JSON.parse(data)
  return json["error"] != 404
end

def user_comments_short(username)
  base = "http://www.reddit.com/user/" + username + '/comments.json?'
  data = Net::HTTP.get_response(URI.parse(base + opts)).body
  json = JSON.parse(data)
  @comments = []
  json["data"]["children"].each do |comment|
    @comments << comment["data"]
  end
  return {comments: @comments}
end

def user_comment_percentiles(username)
  base = "http://www.reddit.com/user/" + username + '/comments.json?'
  data = Net::HTTP.get_response(URI.parse(base)).body
  json = JSON.parse(data)
  subreddits = Hash.new
  c_count = 0
  json["data"]["children"].each do |comment|
    c_count += 1
    c_data = comment["data"]
    if subreddits[c_data["subreddit"]] == nil
      subreddits[c_data["subreddit"]] = 1
    else
      subreddits[c_data["subreddit"]] += 1
    end
  end
  groups = []
  subreddits.each do |s|
    group = Hash.new
    group["label"] = s[0]
    group["value"] = (s[1].to_f / c_count) * 100
    groups << group
  end
  return {data: groups}
end

def user_comment_data(username)
  base = "http://www.reddit.com/user/" + username + '/comments.json?'
  data = Net::HTTP.get_response(URI.parse(base)).body
  json = JSON.parse(data)

  subreddits = Hash.new
  times = []
  c_count = 0
  json["data"]["children"].each do |comment|
    c_count += 1
    c_data = comment["data"]
    if subreddits[c_data["subreddit"]] == nil
      subreddits[c_data["subreddit"]] = 1
    else
      subreddits[c_data["subreddit"]] += 1
    end
  end
  groups = []
  subreddits.each do |s|
    group = Hash.new
    group["label"] = s[0]
    group["value"] = (s[1].to_f / c_count) * 100
    groups << group
  end
  return {data: groups, times: times}
end

def user_data(username)
  url_base = "http://www.reddit.com/user/" + username
  url_ext = "/about.json"
  data = Hash.new

  resp = Net::HTTP.get_response(URI.parse(url_base + url_ext)).body
  json = JSON.parse(resp)

  # Add about data
  data["about"] = json["data"]

  # Load comment data
  url_ext = "/comments.json"
  resp = Net::HTTP.get_response(URI.parse(url_base + url_ext)).body
  json = JSON.parse(resp)

  # Calculate Comments
  comment_count = 0
  upvote_data = []
  downvote_data = []
  data["comment_percentiles"] = Hash.new
  data["upvotes"] = []
  data["downvotes"] = []
  json["data"]["children"].each do |comment|
    comment_count += 1
    comment_data = comment["data"]
    subreddit = comment_data["subreddit"]
    ups = comment_data["ups"]
    downs = comment_data["downs"]
    time = comment_data["created"]
    if data["comment_percentiles"][subreddit] == nil
      data["comment_percentiles"][subreddit] = 1
    else
      data["comment_percentiles"][subreddit] += 1
    end
    upvote_data << [time, ups]
    downvote_data << [time, downs]
  end
  upvotes_group = {"key" => "Comment Upvotes", "values" => upvote_data}
  data["upvotes"] << upvotes_group
  downvotes_group = {"key" => "Comment Downvotes", "values" => downvote_data}
  data["downvotes"] << downvotes_group
  # Calculate percentiles
  data["comment_percentiles"].each do |c|
    data["comment_percentiles"][c[0]] = (c[1].to_f / comment_count) * 100
  end

  # Load submission data
  url_ext = "/submitted.json"
  resp = Net::HTTP.get_response(URI.parse(url_base + url_ext)).body
  json = JSON.parse(resp)

  #Calculate submissions
  submission_count = 0
  upvote_data = []
  downvote_data = []
  data["submission_percentiles"] = Hash.new
  json["data"]["children"].each do |submitted|
    submission_count += 1
    submit_data = submitted["data"]
    subreddit = submit_data["subreddit"]
    ups = submit_data["ups"]
    downs = submit_data["downs"]
    time = submit_data["created"]
    if data["submission_percentiles"][subreddit] == nil
      data["submission_percentiles"][subreddit] = 1
    else
      data["submission_percentiles"][subreddit] += 1
    end
    upvote_data << [time, ups]
    downvote_data << [time, downs]
  end
  upvotes_group = {"key" => "Submission Upvotes", "values" => upvote_data}
  data["upvotes"] << upvotes_group
  downvotes_group = {"key" => "Submission Downvotes", "values" => downvote_data}
  data["downvotes"] << downvotes_group
  # Calculate percentiles
  data["submission_percentiles"].each do |c|
    data["submission_percentiles"][c[0]] = (c[1].to_f / submission_count) * 100
  end

  return data
end