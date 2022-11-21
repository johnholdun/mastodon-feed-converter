class Fetcher
  # These feeds are kind of expensive, so let's only generate them every 15
  # minutes
  TIME_TO_LIVE = 900

  def initialize(actor_url)
    # This used to support Atom feeds, and I would always accidentally use RSS
    # instead so maybe other people have too. Either way, both those options are
    # dead now (at least for Mastodon), so we'll assume that those feeds are
    # content-negotiated in the same way that the ActivityPub Actor resource is—
    # that is, they're all the same URL with different extensions (or Accept
    # headers).
    @actor_url = actor_url.sub(/\.(rss|atom)$/, '')
  end

  def call
    generated_feed = CACHE.get("feed:#{actor_url}")
    feed_fetched = CACHE.get("fetched:#{actor_url}").to_i

    unless generated_feed and (Time.now.to_i - feed_fetched) < TIME_TO_LIVE
      generated_feed = Generator.call(actor_url)
      CACHE.set("feed:#{actor_url}", generated_feed)
      CACHE.set("fetched:#{actor_url}", Time.now.to_i)
    end

    generated_feed
  end

  def self.call(*args)
    new(*args).call
  end

  private

  attr_reader :actor_url
end
