require_relative '../plot'

RSpec.describe Dirt do
  before(:each) do
    @dirt = Dirt.new(0, 0)
  end

  it "is displayed as a black emoji" do
    expect(@dirt.display).to eq("⬛")
  end

  it "will create a Flower when planted" do
    expect(@dirt.plantFlower("🌼")).to be_a Flower
  end

  it "will turn into a seed with 1 neighbor" do
    allow(@dirt).to receive(:neighbors) { [1] }
    expect(@dirt.tick(nil)).to be_a Seed
  end

  it "will turn into a seed with 3 neighbors" do
    allow(@dirt).to receive(:neighbors) { [1, 2, 3] }
    expect(@dirt.tick(nil)).to be_a Seed
  end

  it "will turn into a seed when it has 0 neighbors and rand returns 0" do
    allow(@dirt).to receive(:neighbors) { [] }
    expect(@dirt).to receive(:rand).and_return(0)
    expect(@dirt.tick(nil)).to be_a Seed
  end

  it "won't turn into a seed when it doesn't have 1 or 3 neighbors" do
    expect(@dirt).to receive(:rand).and_return(1)
    [0, 2, 4, 5, 6, 7, 8, 9].each do |neighbors|
      allow(@dirt).to receive(:neighbors) { [1] * neighbors }
      expect(@dirt.tick(nil)).to be_a Dirt
    end
  end
end