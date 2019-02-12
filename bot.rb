require 'mastodon'
require_relative 'config'
require_relative 'garden'

client = Mastodon::REST::Client.new(base_url: @instance_url, bearer_token: @access_token)

last_toot = client.statuses(2432, limit: 1).first
time = DateTime.parse(last_toot.created_at)
# We get the previous status and use that to build the Garden object. This way the program doesn't have to have any memory - each time it gets the state of the garden from the status and the status alone. This makes updating the system or the algorithm straightforward, since I don't have to wrangle with a database or anything. As long as it can load the previous tweet, I can change anything else.
garden = Garden.new(10, 10)
garden.load(last_toot.content)
# garden.addAnimal

# If there are more than 30 notifications, this won't get them all cause Mastodon has a maximum of 30 notifications per request.
# But I decided that in the unlikely situation that >30 people are making suggestions, I can just ignore the extra ones.
suggestions = client.notifications({exclude_types: ["follow", "favourite", "reblog"], limit: 30}).map do |t|
  status = t.status
  # We compare time here because we only want to get suggestions that came in since the previous post. All earlier submissions have presumably already been taken into consideration. Mastodon doesn't have any options to do this natively - you can limit by id but that's by notification id, not status id. So I do it by hand here.
  if(DateTime.parse(status.created_at) > time)
    status.content.scan(Unicode::Emoji::REGEX)
  else
    []
  end
end.flatten.uniq.shuffle

# Move the garden forward in time
garden.tick(suggestions)
client.create_status(garden.display)