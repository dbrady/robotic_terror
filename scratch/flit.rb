require 'gosu'

# this is a scratch/doodle program to see if I can get gosu to track
# the mouse cursor. A triangular "boid" is placed into the window, and
# it flies around and/or just sits there. When the user clicks on the
# screen, the boid flits to that point. If that proves insufficiently
# interesting, upgrade the boid to be constantly moving and let the
# player drop waypoints that the boid must fly to.

# Key features to try out with this scratch:
#
# - Mouse Input
# - Exit on ESC or Ctrl-X
# - Fullscreen mode

require 'ostruct'

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
end

class Boid
  def initialize(position, facing, speed)
    @position, @facing, @speed = position, facing, speed
  end
end
