require_relative '../spec_helper'
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
      assert_in_epsilon @boid.facing, -2.2142974, 0.0001
    end

    it "accelerates toward target" do
      assert_in_epsilon @boid.speed, Boid::MAX_SPEED, 0.0001
    end
  end

  describe "move" do
    before do
    end

    it "moves the boid" do
      speed = Boid::MAX_SPEED
      @boid.set_target 100, 4
      assert_equal @boid.speed, speed
      assert_in_epsilon @boid.facing, 0.0, 0.0001
      @boid.move
      assert_equal @boid.position, Point2D.new(3.0+speed, 4.0)
      @boid.set_target 3.0+speed, 100.0
      assert_in_epsilon @boid.facing, Math::PI/2, 0.0001
      @boid.move
      assert_equal @boid.position, Point2D.new(3.0+speed, 4.0+speed)
    end
  end
end
