require_relative '../plot'

RSpec.describe Dirt do
  before(:each) do
    @seed = Seed.new(0, 0)
  end

  it "is displayed as a sprout" do
    expect(@seed.display).to eq("🌱")
  end

  it "will grow into a flower is one is suggested" do
    allow(@seed).to receive(:neighbors) { [] }

    # It's a test tube because we are testing. I am funny.
    result = @seed.tick(nil, "🧪")
    expect(result).to be_a Flower
    expect(result.display).to eq("🧪")
  end

  it "will grow into a neighboring flower most of the time" do
    allow(@seed).to receive(:neighbors) {["🧪"]}
    expect(@seed).to receive(:rand).and_return(1)

    result = @seed.tick(nil, nil)
    expect(result).to be_a Flower
    expect(result.display).to eq("🧪")
  end

  it "will grow into one of the standard flowers occasionally" do
    allow(@seed).to receive(:neighbors) {["🧪"]}
    expect(@seed).to receive(:rand).and_return(0)

    result = @seed.tick(nil, nil)
    expect(result).to be_a Flower

    expect(result.display == "🧪").to be false
    expect(["🌻", "🌼", "🌹", "🌺", "🌷", "🌵", "🍀"].include?(result.display)).to be true
  end
end