require_relative '../garden'

RSpec.describe Garden do
  before(:each) do
    @garden = Garden.new(2, 2)
  end

  it 'displays all dirt when nothing has been loaded' do
    expect(@garden.display).to eq("⬛⬛\n⬛⬛\n")
  end

  it 'loads from an html string' do
    @garden.load("🧪🧪<br/>🧪🧪")
    expect(@garden.display).to eq("🧪🧪\n🧪🧪\n")
  end

  # This tests if we tick an empty board, it'll add a new plant between 20% and 40% of the time. In most other cases when we're dealing with randomness I just stub the :rand method but with this approach we can test that the micro level probabilities set in Dirt are trickling up correctly to get the macro level probabilities we desire.
  # We run it a thousand times to let the randomness even out but there's still a chance we'll get unlucky and it'll fail. And it slows down the testing suite pretty dramatically. That's the trade-off in tries - the more times we try it, the less often we'll get unlucky but the slower the tests become. 1000 is a pretty good trade off
  # This'd be a bad approach for a production app which was running tests regularly or as part of deploy. But for an art project, where our goal is just to make sure we've tuned the probability correctly, it's fine.
  it 'adds a plant to an board approximately once every 2 or 3 turns' do
    growth = 0
    tries = 1000
    tries.times do
      garden = Garden.new(10, 10)
      garden.tick([])
      growth += garden.display().match?(/[^\n⬛]/) ? 1 : 0
    end
    expect(growth).to be_between(tries * 0.2, tries * 0.4)
  end
end
