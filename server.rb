require 'rubygems'
require 'bundler'
require 'cgi'
require 'open-uri'
require 'json'

Bundler.require

require './generator'
require './fetcher'

ROOT_HTML = File.read('index.html').freeze

CACHE =
  if ENV['MEMCACHEDCLOUD_SERVERS']
    Dalli::Client.new \
      ENV['MEMCACHEDCLOUD_SERVERS'].split(','),
      username: ENV['MEMCACHEDCLOUD_USERNAME'],
      password: ENV['MEMCACHEDCLOUD_PASSWORD']
  else
    Dalli::Client.new
  end

class Server
  def self.call(env)
    request_method = env['REQUEST_METHOD']
    path = env['PATH_INFO']
    query = CGI.parse(env['QUERY_STRING'])

    if request_method == 'GET' && path == '/feed.json' && query.key?('source')
      begin
        result = Fetcher.call(query['source'][0])
        return [200, { 'Content-Type' => 'application/json' }, [result]]
      rescue => e
        puts "Error! #{e}"
        return [500, {}, []]
      end
    end

    if request_method == 'GET' && path == '/'
      return [200, { 'Content-Type' => 'text/html' }, [ROOT_HTML]]
    end

    return [500, {}, []]
  end
end

