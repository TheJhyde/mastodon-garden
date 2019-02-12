# I'm using the unicode-emoji library to detect and classify emojis (https://github.com/janlelis/unicode-emoji)
require 'unicode/emoji'
require_relative 'plot'

class Garden
  def initialize(width, height)
    @width = width
    @height = height
    @garden = []
    width.times do |i|
      @garden[i] = [];
      height.times do |j|
        @garden[i][j] = Dirt.new(i, j)
      end
    end
  end

  def load(text)
    # When you receive Mastodon posts from the API, it includes the html. So we split on <br>
    text.gsub(/<\/*p>/, "").split(/<br\s*\/>/).each_with_index do |line, i|
      line.scan(Unicode::Emoji::REGEX).each_with_index do |c, j|
        if c == "⬛"
          @garden[i][j] = Dirt.new(i, j)
        elsif c == "🌱"
          @garden[i][j] = Seed.new(i, j)
        elsif Unicode::Emoji.list('Animals & Nature').values_at("animal-mammal", "animal-bird", "animal-amphibian", "animal-reptile", "animal-marine", "animal-bug").flatten.include?(c)
          @garden[i][j] = Animal.new(i, j, c)
        else
          @garden[i][j] = Flower.new(i, j, c)
        end
      end
    end
  end

  def plant(x, y, type)
    @garden[x][y] = Flower.new(x, y, type)
  end

  def addAnimal()
    # All these animals eat plants (I'm pretty sure) since that's what they're doing in the garden. Accuracy is not important but sometimes it's fun. There are some extra crabs cause I like crabs.
    animals = %w{🦃 🐓 🦆 🐸 🐌 🐛 🐜 🐝 🐞 🦗 🦓 🦌 🐂 🐃 🐄 🐖 🐑 🐐 🦔 🦀 🦀 🦀 🦀 🦀 🦀 🦀 🦀}
    animal = animals.sample
    # Every animal has a direction is prefers to move in (see the animal class for more info). So we place the animal on the corresponding edge, so it doesn't immediately turn around and leave again. That would be anticlimactic
    direction = animal.codepoints.first % 4
    x = 0
    y = 0
    case direction
    when 0
      x = rand(@width-2)+1
      y = @height - 1
    when 1
      x = @width - 1
      y = rand(@height-2)+1
    when 2
      x = rand(@width-2)+1
      y = 0
    when 3
      x = 0
      y = rand(@height-2)+1
    else
      x = rand(@width-2)+1
      y = rand(@height-2)+1
    end
    @garden[x][y] = Animal.new(x, y, animal)    
  end

  def display
    @garden.reduce("") do |acc, line|
      line_text = line.reduce("") do |acc, plot|
        acc + plot.display();
      end
      acc + line_text + "\n"
    end
  end

  def tick(suggestions)
    new_garden = []
    animals = []
    @width.times do |i|
      new_garden[i] = []
      @height.times do |j|
        if @garden[i][j].is_a?(Seed)
          # Suggestions are popped off the suggestion array so they only get used once
          # And there's only a 1/5 chance of them being used so that all the suggestions don't get used in the top left of the garden
          # This means that some suggestions won't be applied. But, as with the 30 notification limit, I'm fine with that
          new_garden[i][j] = @garden[i][j].tick(@garden, rand(5) == 0 ? suggestions.pop : nil)
        elsif(@garden[i][j].is_a?(Animal))
          animals.push(@garden[i][j])
          new_garden[i][j] = @garden[i][j]
        else
          new_garden[i][j] = @garden[i][j].tick(@garden)
        end
      end
    end

    # Animals move, so they update multiple squares. They have to be updated after all the other elements so they aren't overwritten
    animals.each do |animal|
      new_garden = animal.tick(new_garden)
    end

    @garden = new_garden
    # Add an animal, occasionally. The more animals there are already, the less likely it is we'll add a new one, with the lowest chance being 1 out of 20. Since the bot updates every hour, that means an animal will show up ~a day after the previous animal left. I think? I never really did the math on this, I'm just putting in values and seeing if I like how the outputs feel
    if rand(20 * (animals.length + 1)) == 0
      addAnimal
    end
  end
end