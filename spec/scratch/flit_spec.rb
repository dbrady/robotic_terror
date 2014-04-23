require 'minitest/autorun'

require_relative '../../scratch/flit'

describe Boid do
  before do
    @boid = Boid.new 3.0, 4.0
  end

  describe "set_target" do
    before do
      @boid.set_target 0.0, 0.0
    end

    it "turns to face target" do
      assert_in_epsilon @boid.facing, -2.2142974
    end

    it "accelerates toward target" do
      assert_in_epsilon @boid.speed, Boid::MAX_SPEED
    end
  end

  describe "move" do
    before do
    end

    it "moves the boid" do
      @boid.set_target 100, 4
      assert_equal @boid.speed, 10 # this spec depends on Boid::MAX_SPEED==10
      assert_in_epsilon @boid.facing, 0.0
      @boid.move
      assert_equal @boid.position, Point2D.new(13.0, 4.0)
      @boid.set_target 13.0, 100.0
      assert_in_epsilon @boid.facing, Math::PI/2
      @boid.move
      assert_equal @boid.position, Point2D.new(13.0, 14.0)
    end
  end
end
