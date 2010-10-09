class Tweet # {{{
  include DataMapper::Resource
  include ActionView::Helpers::DateHelper

  property :id,         Serial
  property :tweet_id,   Integer, :max => 9223372036854775808
  property :text,       String, :length => 140
  property :created_at, DateTime

  def permalink
    "/statuses/#{self.tweet_id}"
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

  has n, :mentions

  def permalink
    "/mentions/#{self.username}"
  end

end # }}}

class Tag # {{{
  include DataMapper::Resource

  property :id, Serial
  property :tag, String

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

end # }}}

class Hashtag # {{{
  include DataMapper::Resource

  property :id, Serial
  belongs_to :tag
  belongs_to :tweet

end # }}}

DataMapper.finalize