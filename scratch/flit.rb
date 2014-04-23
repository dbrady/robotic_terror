require 'gosu'
require_relative '../lib/point2d'
require_relative '../lib/framerate_counter'
require 'time'

# this is a scratch/doodle program to see if I can get gosu to track
# the mouse cursor. A target and a triangular "boid" are placed into
# the window, and the boid flits to the target. Clicking the screen
# places the target. Boid can either stop or wander aimlessly once it
# reaches the target, don't care.

# TODO / Key features to try out with this scratch:
#
# x Exit on ESC or Ctrl-X
# - drop a random target whenever the boid reaches the target
# - Mouse Input drops a target
# x Fullscreen mode
# - Mouse input drops a waypoint; additional clicks drop additional
#     waypoints

module ZOrder
  Background, GameBoidPoop, GameTarget, GameBoid, UI = *0..4
end

class Boid
  attr_reader :z, :position, :facing, :speed, :target

  MAX_SPEED = 10.0

  NOSE_COLOR = 0xffffffff
  TAIL_COLOR = 0xffff0000
  LENGTH = 20.0
  WIDTH = 10.0

  def initialize(x, y, facing=0.0, speed=MAX_SPEED, z=ZOrder::GameBoid)
    @z=0
    set_position x, y
    @facing, @speed = facing, speed

    @hull_points = [
                    [LENGTH/2.0, 0.0, NOSE_COLOR],
                    [-LENGTH/2.0, -WIDTH/2.0, TAIL_COLOR],
                    [-LENGTH/2.0, WIDTH/2.0, TAIL_COLOR]
                   ].flatten
  end

  def set_position(x, y)
    @position = Point2D.new(x,y)
  end

  def set_target(target_x, target_y)
    @target = Point2D.new(target_x, target_y)
    turn_to_face(@target)
    @speed = MAX_SPEED
  end

  def clear_target
    @target = nil
    @speed = 0.0
  end

  def move
    speed_vector = Point2D.new Math::cos(facing) * speed, Math::sin(facing) * speed
    @position = position + speed_vector
  end

  def x; position.x; end
  def y; position.y; end

  def draw_on(surface)
    surface.translate(x,y) do
      surface.rotate(Gosu.radians_to_degrees(facing)) do
        surface.draw_triangle *@hull_points
      end
    end
  end

  private

  def turn_to_face(target)
    @facing = position.angle_to target
  end
end

class Target
  attr_accessor :x, :y, :z

  COLOR = 0xffffff00
  RADIUS = 5.0

  def initialize(x=0.0, y=0.0, z=ZOrder::GameTarget)
    @x, @y, @z = x, y, z
  end

  def set_position(x, y)
    @x, @y = x, y
  end

  def draw_on(surface)
    surface.draw_quad x+RADIUS, y+RADIUS, COLOR,
                      x+RADIUS, y-RADIUS, COLOR,
                      x-RADIUS, y-RADIUS, COLOR,
                      x-RADIUS, y+RADIUS, COLOR,
                      z
  end
end

class BoidPoop
  attr_reader :x, :y, :z

  COLOR = 0xff990000
  RADIUS = 1.0

  def initialize(x, y, z=ZOrder::GameBoidPoop)
    @x, @y, @z = x, y, z
  end

  def draw_on(surface)
    surface.draw_quad x+RADIUS, y+RADIUS, COLOR,
                      x+RADIUS, y-RADIUS, COLOR,
                      x-RADIUS, y-RADIUS, COLOR,
                      x-RADIUS, y+RADIUS, COLOR,
                      z
  end
end

class Crosshair
  attr_reader :width, :height, :x, :y, :z

  COLOR = 0xffff0000
  RETICLE_RADIUS = 5.0
  INNER_RADIUS = 10.0
  OUTER_RADIUS = 40.0

  def initialize(width, height, x=0.0, y=0.0, z=ZOrder::UI)
    @height, @width, @x, @y, @z = height, width, x, y, z
  end

  def set_position(x, y)
    @x, @y = x, y
  end

  def draw_on(surface)
    surface.draw_line x, y-RETICLE_RADIUS, COLOR, x, y+RETICLE_RADIUS, COLOR, z
    surface.draw_line x-RETICLE_RADIUS, y, COLOR, x+RETICLE_RADIUS, y, COLOR, z

    surface.draw_line x+INNER_RADIUS, y, COLOR, x+OUTER_RADIUS, y, 0, z
    surface.draw_line x-INNER_RADIUS, y, COLOR, x-OUTER_RADIUS, y, 0, z
    surface.draw_line x, y+INNER_RADIUS, COLOR, x, y+OUTER_RADIUS, 0, z
    surface.draw_line x, y-INNER_RADIUS, COLOR, x, y-OUTER_RADIUS, 0, z
  end
end

class FlitWindow < Gosu::Window
  attr_reader :center_x, :center_y, :font, :height, :width
  attr_reader :target, :boid, :poops, :crosshair, :framerate_counter

  def initialize
    @width, @height = 1920, 1080
    @center_x, @center_y = @width / 2, @height / 2

    super @width, @height, true
    @target = nil
    @poops = []
    @boid = Boid.new @center_x, @center_y, 0.0, 0.0, ZOrder::GameBoid
    #@boid.set_target @target.x, @target.y
    @font = Gosu::Font.new(self, 'courier', 20) # Gosu::default_font_name, 20)
    metrics_image = Gosu::Image.from_text(self, "fps: 60", 'courier', 20)
    @framerate_x = @width - (metrics_image.width+10)
    @last_sec = -1
    @crosshair = Crosshair.new @width, @height
    @framerate_counter = FramerateCounter.new 0xffffff00
  end

  def button_down(id)
    exit if id == 1 # ESC key
    # Use this for target-on-click
    # if id == Gosu::MsLeft
    #   @target = Target.new mouse_x, mouse_y
    #   boid.set_target target.x, target.y
    # end
  end

  def update
    # Use this for draggable target
    if button_down?(Gosu::MsLeft)
      @target = Target.new unless target
      @target.set_position mouse_x, mouse_y
      boid.set_target target.x, target.y
    end


    if target_available?
      if target_reached?
        # destroy target
        @target = nil
        boid.clear_target
      else
        boid.move
      end
    else
      # boid sits around, bored
    end

    now = DateTime.now
    frac = (now.second_fraction * 100).to_i
    if @last_sec != frac
      poops.push BoidPoop.new(boid.x, boid.y)
      poops.shift if poops.size > 1000
      @last_sec = frac
    end

    crosshair.set_position mouse_x, mouse_y
  end

  def draw
    framerate_counter.update

    # draw stuff
    draw_background_on self
    poops.each {|poop| poop.draw_on self }
    target.draw_on self if target
    boid.draw_on self
    framerate_counter.draw_on self, @framerate_x, 10
    crosshair.draw_on self
  end

  private

  def target_available?
    !target.nil?
  end

  def target_reached?
    (target.x-boid.x).abs < Boid::MAX_SPEED && (target.y-boid.y).abs < Boid::MAX_SPEED
  end

  def random_target
    Target.new rand(width), rand(height)
  end

  def draw_background_on(surface)
    surface.draw_quad 0,0,0, 0,height,0, width,height,0, width,0,0, ZOrder::Background
  end
end

if $0 == __FILE__
  # srand Time.now.to_i
  srand 42
  FlitWindow.new.show
end
