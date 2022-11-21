require './strip_heredoc'

class Generator
  def initialize(actor_url)
    @actor_url = actor_url
  end

  def call
    actor = get(actor_url)
    outbox_url = actor[:outbox]
    outbox = get(outbox_url)

    first_page = outbox[:first]
    items = get_items(first_page)
    # TODO: More items?

    JSON.pretty_generate \
      version: 'https://jsonfeed.org/version/1',
      title: actor[:name],
      description: actor[:summary],
      home_page_url: actor[:url],
      feed_url: "http://mastodon-feed-converter.johnholdun.com/feed.json?source=#{CGI.escape(actor_url)}",
      icon: actor.dig(:icon, :url),
      items: items,
      author: {
        name: actor[:name],
        avatar: actor.dig(:icon, :url)
      }
  end

  def self.call(*args)
    new(*args).call
  end

  private

  attr_reader :actor_url

  # TODO: Cache each response, add etag/if-modified support
  def get(url)
    response = open(url, 'Accept' => 'application/activity+json').read
    JSON.parse(response, symbolize_names: true)
  end

  def get_items(url)
    get(url)[:orderedItems].map do |item|
      object = item[:object]
      object = get(object) if object.is_a?(String)

      json_entry =
        {
          id: item[:id],
          content_html: object[:content],
          url: object[:id],
          date_published: item[:published]
        }

      (object[:attachment] || []).each do |attachment|
        json_entry[:content_html] +=
          if %w(image/jpeg image/jpg image/png image/gif image/webp).include?(attachment[:mediaType])
            %Q(<p><img alt=#{attachment[:name].to_s.inspect} src="#{attachment[:url]}"></p>)
          else
            %Q(<p>Unexpected attachment: <code>#{JSON.pretty_generate(attachment)}</code></p>)
          end
      end

      if object[:summary]
        json_entry[:title] = object[:summary]
      end

      if item[:type] == 'Announce'
        json_entry[:content_html] = strip_heredoc(<<-SHARE).strip
          <p><a href="#{object[:attributedTo]}">#{object[:attributedTo]}</a>:</p>
          <blockquote>#{json_entry[:content_html]}</blockquote>
        SHARE
      end

      json_entry
    end
  end
end
