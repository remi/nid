require 'sinatra/base'
require 'haml'
require 'json'
require 'yaml'
require 'open-uri'
require 'twitter'

# Datamapper
require 'dm-core'
require 'dm-migrations'

DataMapper::Logger.new $stdout, :debug
DataMapper.setup :default, 'mysql://localhost/nid_development'

# ActionView
require 'action_view'

class Nid < Sinatra::Base

  require 'app/models'
  require 'app/importer'

  NID_CONFIG = YAML.load_file File.join(File.dirname(__FILE__), "config/nid.yml")

  # Routes

  # sinatra configuration {{{
  enable :static
  set :public, File.join(File.dirname(__FILE__), "public")
  # }}}

  get "/import" do # {{{
    Importer.import
    "Done importing."
  end # }}}

  get "/update" do # {{{
    Importer.update
    "Done updating."
  end # }}}

  get "/" do # {{{
    @tweets = Tweet.all :limit => 20, :order => :created_at.desc
    haml :index
  end # }}}

  get "/statuses/:id" do # {{{
    @tweets = [].push Tweet.first :tweet_id => params[:id]
    haml :index
  end # }}}

  get "/mentions" do # {{{
    @users = User.all :order => :mention_count.desc
    @max_mentions = @users.first.mention_count

    @subtitle = "Mentionned users"
    haml :users
  end # }}}

  get "/mentions/:username" do # {{{
    user = User.first :username => params[:username]
    return "error" unless user

    @tweets = Mention.all(:user_id => user.id).tweets.all :order => :created_at.desc

    @subtitle = "Tweets mentionning #{user.username}"
    haml :index
  end # }}}

  get "/tags/:tag" do # {{{
    tag = Tag.first :tag => params[:tag]
    return "error" unless tag

    @tweets = Hashtag.all(:tag_id => tag.id).tweets.all :order => :created_at.desc

    @subtitle = "Tweets tagged with #{tag.hashtag}"
    haml :index
  end # }}}

  get "/:year" do # {{{
    start_date = DateTime.parse "#{params[:year]}-01-01 00:00:00"
    end_date = DateTime.parse "#{params[:year]}-12-31 23:59:59"
    @tweets = Tweet.all :created_at => (start_date..end_date), :order => :created_at.desc

    @subtitle = "Tweets posted in #{params[:year]}"
    haml :index
  end # }}}

  get "/:year/:month" do # {{{
    start_date = DateTime.parse "#{params[:year]}-#{params[:month]}-01 00:00:00"
    end_date = DateTime.parse "#{params[:year]}-#{params[:month]}-31 23:59:59"
    @tweets = Tweet.all :created_at => (start_date..end_date), :order => :created_at.desc

    @subtitle = "Tweets posted in #{params[:month]} #{params[:year]}"
    haml :index
  end # }}}

  get "/:year/:month/:day" do # {{{
    start_date = DateTime.parse "#{params[:year]}-#{params[:month]}-#{params[:day]} 00:00:00"
    end_date = DateTime.parse "#{params[:year]}-#{params[:month]}-#{params[:day]} 23:59:59"
    @tweets = Tweet.all :created_at => (start_date..end_date), :order => :created_at.desc

    @subtitle = "Tweets posted on #{params[:day]} #{params[:month]} #{params[:year]}"
    haml :index
  end # }}}

end
# vim: fdm=marker:
