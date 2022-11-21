# ActivityPub to JSON Feed

Turns ActiviytPub outboxes into reformatted JSON Feeds, inspired by [micro.blog](https://micro.blog)

## Features

The feeds created by this service have the following changes:

- Titles are omitted—a status is just a body
- If there is a Content Warning on the status, _that_ becomes the title
- Reposts are presented Tumblr-style, with the author's name followed by the original post in a blockquote
- Images are included in the post body

## Instructions

You can convert an existing Atom feed provided by Mastodon into a converted JSON feed by passing it as a `source` query parameter to `feed.json`:

[http://mastodon-feed-converter.johnholdun.com/feed.json?source=**https://mastodon.social/users/johnholdun.atom**](http://mastodon-feed-converter.johnholdun.com/feed.json?source=https://mastodon.social/users/johnholdun.atom)

You can subscribe directly to that feed in your feed reader. Every time your reader requests it, it will fetch that latest version of the source feed and convert it on the fly.

## Hosting it yourself

I make no guarantees that this service will remain functional, but I can tell you that I use it personally to read statuses from Mastodon users, so it will probably remain functional for a while. If you're interested in a more self-sufficient approach, [this repo](https://github.com/johnholdun/mastodon-feed-converter) can be pushed to Heroku or any other server and work without any special configuration.

## Issues

It's not perfect, and some content doesn't show up correctly. Check this project's [GitHub Issues](https://github.com/johnholdun/mastodon-feed-converter/issues) and submit a new issue if you've noticed something that hasn't already been reported. (You're also welcome to try fixing it yourself and submitting a pull request!)

## Who did this?

I did. I'm [John Holdun](https://johnholdun.com).

## Why isn't this a PR against Mastodon?

While I think these changes satisfy a very general use case, they seem too drastically different from the existing Mastodon feeds. A very brief browse of existing conversations about RSS and Atom feeds in Mastodon suggested that pitching this as an official enhancement would not be a good use of anyone's time.

That said, if you have an idea for how to make this official, or you're interested in a patch for your own installation of Mastodon, [let me know](mailto:john@johnholdun.com)! Maybe I can help you make it happen.
