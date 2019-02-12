This is the code for a mastodon bot that posts a little emoji garden. It's running over at [@garden@botsin.space](https://botsin.space/@garden). This bot runs on ruby and requires two gems - [the mastodon api](https://github.com/tootsuite/mastodon-api) and [emoji regex](https://github.com/janlelis/unicode-emoji). It'll also require a config.rb file to hold the instance url, bearer token, and id for the account you're trying to post too.

The main script is bot.rb. To run:
```ruby
ruby bot.rb
```

I run garden off a raspberry pi, scheduled with the cron tab (`26 * * * * cd garden && ruby bot.rb`). I've put comments the individual scripts describing some of the choices I made while making the bot.