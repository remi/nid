class Tweet # {{{
  include DataMapper::Resource
  include ActionView::Helpers::DateHelper

  property :id,         Serial
  property :tweet_id,   Integer, :max => 9223372036854775808
  property :text,       String, :length => 180
  property :created_at, DateTime

  def permalink
    date = self.created_at
    "/#{date.year}/#{date.month.to_s.rjust(2,"0")}/#{date.day.to_s.rjust(2,"0")}/#{self.tweet_id}"
  end

  def text_with_markup
    self.text.gsub /@([a-z0-9_]+)/i, '<a href="'+User.new(:username => '\1').permalink+'">@\1</a>'
  end

  def relative_date
    time_ago_in_words self.created_at
  end

  has n, :mentions
  has n, :hashtags

end # }}}

class User # {{{
  include DataMapper::Resource

  property :id, Serial
  property :user_id, Integer, :max => 9223372036854775808
  property :username, String
  property :mention_count, Integer, :default => 0

  has n, :mentions

  def permalink
    "/mentions/#{self.username}"
  end

end # }}}

class Tag # {{{
  include DataMapper::Resource

  property :id, Serial
  property :tag, String
  property :hashtag_count, Integer, :default => 0

  has n, :hashtags

  def permalink
    "/tags/#{self.tag}"
  end

  def hashtag
    "\##{self.tag}"
  end

end # }}}

class Mention # {{{
  include DataMapper::Resource

  property :id, Serial
  belongs_to :user
  belongs_to :tweet

  before :save do
    self.user.mention_count += 1
    self.user.save
  end

end # }}}

class Hashtag # {{{
  include DataMapper::Resource

  property :id, Serial
  belongs_to :tag
  belongs_to :tweet

  before :save do
    self.tag.hashtag_count += 1
    self.tag.save
  end

end # }}}

DataMapper.finalize
