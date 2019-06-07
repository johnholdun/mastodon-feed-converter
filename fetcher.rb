class Fetcher
  TIME_TO_LIVE = 60

  def initialize(feed_url)
    @feed_url = feed_url
  end

  def call
    generated_feed = CACHE.get("feed:#{feed_url}")
    feed_fetched = CACHE.get("fetched:#{feed_url}").to_i

    unless generated_feed and (Time.now.to_i - feed_fetched) < TIME_TO_LIVE
      # TODO: Add etag/if-modified support
      feed_content = open(feed_url).read
      generated_feed = Generator.call(feed_url, feed_content)
      CACHE.set("feed:#{feed_url}", generated_feed)
      CACHE.set("fetched:#{feed_url}", Time.now.to_i)
    end

    generated_feed
  end

  def self.call(*args)
    new(*args).call
  end

  private

  attr_reader :feed_url
end
