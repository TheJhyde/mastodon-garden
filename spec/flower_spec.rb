require_relative '../plot'

RSpec.describe Dirt do
  before(:each) do
    @flower = Flower.new(0, 0, "🌼")
  end

  it "will turn to dirt after a tick if it's old" do
    flower = Flower.new(0, 0, "🥀")
    expect(flower.tick(nil)).to be_a Dirt
  end

  it "will turn old if it's too crowded" do
    allow(@flower).to receive(:neighbors) { [1, 2, 3, 4, 5, 6] }
    expect(@flower.tick(nil).display()).to eq "🥀"
  end

  it "will turn old if rand returns 0" do
    allow(@flower).to receive(:neighbors) { [1] }
    expect(@flower).to receive(:rand).and_return(0)

    expect(@flower.tick(nil).display()).to eq "🥀"
  end

  it "will keep living otherwise" do
    allow(@flower).to receive(:neighbors) { [1] }
    expect(@flower).to receive(:rand).and_return(1)

    expect(@flower.tick(nil)).to eq @flower
  end  
end