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
  begin
    uri = URI.parse(url)
  rescue URI::InvalidURIError
    return false
  end
  data = Net::HTTP.get_response(uri).body
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
  karma_data = []
  data["comment_percentiles"] = Hash.new
  data["comment_karma"] = []
  json["data"]["children"].each do |comment|
    comment_count += 1
    comment_data = comment["data"]
    subreddit = comment_data["subreddit"]
    karma = comment_data["ups"] - comment_data["downs"]
    time = comment_data["created"].to_i
    if data["comment_percentiles"][subreddit] == nil
      data["comment_percentiles"][subreddit] = 1
    else
      data["comment_percentiles"][subreddit] += 1
    end
    karma_data << [time, karma]
  end
  karma_group = {"key" => "Comment Karma", "values" => karma_data}
  data["comment_karma"] << karma_group
  # Calculate percentiles
  groups = []
  data["comment_percentiles"].each do |c|
    group = Hash.new
    group["label"] = c[0]
    group["value"] = (c[1].to_f / comment_count) * 100
    groups << group
  end
  data["comment_percentiles"] = groups

  # Load submission data
  url_ext = "/submitted.json"
  resp = Net::HTTP.get_response(URI.parse(url_base + url_ext)).body
  json = JSON.parse(resp)

  #Calculate submissions
  submission_count = 0
  karma_data = []
  data["link_karma"] = []
  data["submission_percentiles"] = Hash.new
  json["data"]["children"].each do |submitted|
    submission_count += 1
    submit_data = submitted["data"]
    subreddit = submit_data["subreddit"]
    karma = submit_data["ups"] - submit_data["downs"]
    time = submit_data["created"].to_i
    if data["submission_percentiles"][subreddit] == nil
      data["submission_percentiles"][subreddit] = 1
    else
      data["submission_percentiles"][subreddit] += 1
    end
    karma_data << [time, karma]
  end
  karma_group = {"key" => "Link Karma", "values" => karma_data}
  data["link_karma"] << karma_group
  # Calculate percentiles
  groups = []
  data["submission_percentiles"].each do |c|
    group = Hash.new
    group["label"] = c[0]
    group["value"] = (c[1].to_f / submission_count) * 100
    groups << group
  end
  data["submission_percentiles"] = groups

  return data
end