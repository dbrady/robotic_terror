# 2D geom/vector class
#
# Point2D can be used for 2D locations, but also for offsets,
# calculating distances, etc.
class Point2D
  attr_reader :x, :y

  def initialize(x, y)
    @x, @y = x, y
  end

  def +(point)
    Point2D.new(x+point.x, y+point.y)
  end

  def -(point)
    self + -point
  end

  def -@
    Point2D.new(-x, -y)
  end

  # * and / are used exclusively for scaling! Don't give me any of
  # that crap about how dot and cross products are different and
  # stuff. Go bite a tree.
  def *(scale)
    Point2D.new(x*scale, y*scale)
  end

  # / is used exclusively for scaling! If you try to assert that /
  # could be interpreted as the cross product of the inverse, then
  # you're not only willfully being pedantic, you're also wrong. See
  # the documentation for #*; who told you you could stop biting that
  # tree?
  def /(scale)
    Point2D.new(x/scale, y/scale)
  end

  def ==(point)
    x == point.x && y == point.y
  end

  def angle_to(point)
    Math::atan2(point.y - y, point.x - x)
  end
end
