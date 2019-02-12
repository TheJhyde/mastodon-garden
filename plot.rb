class Plot
  def initialize(x, y)
    @x = x
    @y = y
  end

  # These ranges define all of the plot's neighbors
  def xRange(max)
    (@x > 0 ? @x - 1 : @x)..(@x < max - 1 ? @x + 1 : @x) 
  end

  def yRange(max)
    (@y > 0 ? @y - 1 : @y)..(@y < max - 1 ? @y + 1 : @y)
  end

  def neighbors(garden)
    flowers = []
    xRange(garden.length).each do |i|
      yRange(garden[i].length).each do |j|
        if garden[i][j] != self && garden[i][j].is_a?(Flower) && !garden[i][j].old
          flowers.push(garden[i][j].type)
        end
      end
    end
    flowers
  end
end

class Dirt < Plot
  # I'm not 100% happy with this emoji as the dirt image. It looks good on firefox if you're using the dark mastodon theme but the google emoji set gives the black box a white outline and it's more obvious on the light theme. But I'm not sure what'd be better so I'm sticking with this.
  def display
    "⬛"
  end

  def plantFlower(type)
    Flower.new(@x, @y, type)
  end

  def tick(garden)
    flowers = neighbors(garden)
    # If an empty flot has 1 or 3 neighbors, it'll plant a seed. Why those values? No particular reason. I try out different rules and see what gives an output I like.
    # Or, if it has zero neighbors, it'll plant a seed one out of 500 times
    # 1/500 seems pretty rare, but in an empty garden there will be 100 empty Dirt plots. And we don't care about each individual plot's chance so much as the chance for the garden overall to grow new seeds - we only want it to happen to 1 or 2 plots at a time and even then, not to happen on most ticks
    if (flowers.length == 1 || flowers.length == 3) || (flowers.length == 0 && rand(500) == 0)
      return Seed.new(@x, @y)
    end
    return self
  end
end

class Seed < Plot
  def initialize(*args)
    super(*args)
    # These are the standard flowers seeds will grow into. However any emoji that's not being used for something else (i.e. the seed emoji or one of the animal ones) can be a flower
    @flowers = ["🌻", "🌼", "🌹", "🌺", "🌷", "🌵", "🍀"]
  end

  def display
    "🌱"
  end

  def tick(garden, suggestion)
    flowers = neighbors(garden)
    # If there's a suggestion, we always use that. If not, the flower grows to be one of it's neighbors most of the time. But occasionally it'll grow to be one of the standard set of flowers. This is a way to get new flowers on the board from time to time.
    # If someone suggested an animal, it'd grow from the seed and then become an animal and start moving around in the next tick. Which I find amusing.
    if !suggestion.nil?
      return Flower.new(@x, @y, suggestion)
    elsif flowers.length > 0 && rand(7) != 0
      return Flower.new(@x, @y, flowers.uniq.sample)
    else
      return Flower.new(@x, @y, @flowers.sample)
    end
  end
end

class Alive < Plot
  attr_reader :type
  def initialize(x, y, type)
    @type = type
    super(x, y)
  end

  def display
    @type
  end

end

class Flower < Alive
  attr_reader :type, :old

  def initialize(x, y, type)
    super(x, y, type)
    # Every old plant looks the same, regardless of what it looked like before. That is science tells us.
    @old = (type == "🥀")
  end

  def tick(garden)
    if @old
      return Dirt.new(@x, @y)
    end
    flowers = neighbors(garden)
    # I load the previous tweet each time, so it's not possible to give flowers a set age beforehand - I have no idea how long a given flower has been on the board. So it's random instead - each turn a flower has a chance to grow old.
    # A flower will also grow old if it's too crowded. I think the board looks bad if it's all flowers and no empty space, so this serves as a limiter.
    if flowers.length >= 6 || rand(8) == 0
      return Flower.new(@x, @y, "🥀")
    end
    self
  end
end

class Animal < Alive
  def direction_val
    @type.codepoints.first % 4
  end

  def tick(garden)
    # Each animal has one direction they won't go in, so through a series of random selections they'll average out towards moving in the opposite direction. This way animals cross the board from one side to the other, letting them eat a lot of plants and be on the board for a while.
    # The direction is selected based on the emoji's codepoint. Every animal of the same type will have the same direction and I can figure out the direction just based on the emoji - I don't have too store any information between ticks.
    directions = [[0, 1], [1, 0], [0, -1], [-1, 0]]
    directions.delete_at(direction_val)
    # Animals move twice.
    2.times do
      garden[@x][@y] = Dirt.new(@x, @y)
      direction = directions.sample
      new_x = @x + direction[0]
      new_y = @y + direction[1]
      # If the animal wanders off the edge of the map, they're gone. Goodbye animal!
      if new_x >= 0 && new_x < garden.length && new_y >= 0 && new_y < garden[new_x].length
        @x = new_x
        @y = new_y
        garden[@x][@y] = self
      else
        break
      end
    end
    return garden
  end
end