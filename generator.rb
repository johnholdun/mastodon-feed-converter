require './strip_heredoc'

class Generator
  def initialize(feed_url, feed_content = nil)
    @feed_url = feed_url
    @feed_content = feed_content
  end

  def call
    @feed_content ||= open(feed_url).read
    doc = Nokogiri::XML(feed_content)

    items =
      doc.css('feed entry').map do |entry|
        url = entry.css('link[rel="alternate"][type="text/html"]').first[:href]

        published = entry.css('published').first.text
        modified = entry.css('updated').first.text

        json_entry =
          {
            id: url,
            content_html: entry.css('content[type="html"]').first.text,
            url: url,
            date_published: published
          }

        json_entry[:date_modified] = modified if modified != published

        image = entry.css('link[rel="enclosure"]').first

        if image and %w(image/jpeg image/jpg image/png image/gif).include?(image[:type])
          json_entry[:content_html] += %Q(<p><img src="#{image[:href]}"></p>)
        end

        if entry.xpath('activity:verb').text == 'http://activitystrea.ms/schema/1.0/share'
          shared_object = entry.xpath('activity:object')
          shared_url = shared_object.css('link[rel="alternate"][type="text/html"]').first[:href]
          shared_author = shared_object.css('author email').text
          json_entry[:content_html] = strip_heredoc(<<-SHARE).strip
            <p><a href="#{shared_url}">#{shared_author}</a>:</p>
            <blockquote>#{json_entry[:content_html]}</blockquote>
          SHARE
        end

        summary = entry.xpath('summary').to_s.strip

        unless summary.size.zero?
          json_entry[:title] = summary
        end

        json_entry
      end

    JSON.pretty_generate \
      version: 'https://jsonfeed.org/version/1',
      title: doc.css('feed > title').text,
      description: doc.css('feed > subtitle').text,
      home_page_url: doc.css('feed > author > uri').text,
      feed_url: "https://example.com/doc.json?source=#{CGI.escape(feed_url)}",
      icon: doc.css('feed > logo').text,
      items: items
  end

  def self.call(*args)
    new(*args).call
  end

  private

  attr_reader :feed_url, :feed_content
end
