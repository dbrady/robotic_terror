require 'minitest/autorun'

require_relative '../../scratch/flit'

describe Point2D do
  before do
    @point = Point2D.new 3, 4
    @point2 = Point2D.new 1, 3
  end

  describe '#==' do
    it "returns true if point's x and y are equal" do
      assert_equal @point, Point2D.new(3, 4)
    end
  end

  # describe '#close_to?' do
  # end
  
  describe '#-@ (unary minus)' do
    it "inverts point's x and y" do
      assert_equal -@point, Point2D.new(-3, -4)
    end
  end

  describe '#+' do
    it "adds points together" do
      assert_equal @point + @point2, Point2D.new(4, 7)
    end
  end

  describe '#-' do
    it "subtracts points from each other" do
      assert_equal @point - @point2, Point2D.new(2, 1)
    end
  end

  describe "#*" do
    it "scales the point up" do
      assert_equal @point * 2, Point2D.new(6, 8)
    end
  end

  describe "#/" do
    it "scales the point down like Integers do" do
      assert_equal @point2 / 2, Point2D.new(0, 1)
    end

    it "scales the point like Floats do" do
      point = @point / 2.0
      assert_in_epsilon point.x, 1.5
      assert_in_epsilon point.y, 2.0
    end
  end

end
