require 'gosu'
require 'time'

module ZOrder
  Background, ClockFace, ClockHands, UI = *0..3
end

class Clock
  def initialize(width, height)
    @width, @height = width, height
    @second_length = radius * 0.8
    @minute_length = radius * 0.7
    @hour_length = radius * 0.5

    @hour_ticks = [0.81, 0.99].map {|t| t*radius}
    @minute_ticks = [0.9, 0.99].map {|t| t*radius}

    @second_color, @minute_color, @hour_color, @face_color = 0xffff0000, 0xff0000ff, 0xff00ff00, 0xffffffff
  end

  def radius
    @radius ||= [@width, @height].min / 2
  end

  def center_x
    @center_x ||= @width / 2
  end

  def center_y
    @center_y ||= @height / 2
  end

  def draw_label_on(surface, time=nil, x=10, y=10)
    time ||= DateTime.now
    x ||= center_x
    y ||= center_y
    surface.font.draw("Time: %2d:%02d:%02d" % [time.hour, time.minute, time.second], x, y, ZOrder::ClockFace, 1.0, 1.0, @face_color)
  end

  def draw_on(surface, time=nil, x=nil, y=nil)
    time ||= DateTime.now
    x ||= center_x
    y ||= center_y
    hour, minute, second = time.hour, time.minute, time.second
    @center_x, @center_y = x, y

    # draw clock face
    60.times do |min|
      x1, y1 = hand_endpoints ticks_to_angle(min, 60), @minute_ticks.first
      x2, y2 = hand_endpoints ticks_to_angle(min, 60), @minute_ticks.last
      surface.draw_line x1, y1, @face_color, x2, y2, @face_color, ZOrder::ClockFace
    end

    12.times do |hr|
      x1, y1 = hand_endpoints ticks_to_angle(hr, 12), @hour_ticks.first
      x2, y2 = hand_endpoints ticks_to_angle(hr, 12), @hour_ticks.last
      surface.draw_line x1, y1, @face_color, x2, y2, @face_color, ZOrder::ClockFace
    end

    # draw clock hands
    second += time.second_fraction
    minute += second/60.0
    hour += minute/60.0

    draw_second_hand_on surface, second
    draw_minute_hand_on surface, minute
    draw_hour_hand_on surface, hour
  end

  def ticks_to_angle(ticks, ticks_per_revolution)
    (2*Math::PI*ticks)/ticks_per_revolution.to_f-(Math::PI/2)
  end

  def draw_hand_on(surface, angle, length, color)
    x, y = hand_endpoints angle, length
    surface.draw_line @center_x, @center_y, color, x, y, color, ZOrder::ClockHands
  end

  def draw_second_hand_on(surface, second)
    draw_hand_on surface, ticks_to_angle(second, 60), @second_length, @second_color
  end

  def draw_minute_hand_on(surface, minute)
    draw_hand_on surface, ticks_to_angle(minute, 60), @minute_length, @minute_color
  end

  def draw_hour_hand_on(surface, hour)
    draw_hand_on surface, ticks_to_angle(hour, 12), @hour_length, @hour_color
  end

  def hand_endpoints(angle, length)
    [Math::cos(angle)*length+@center_x, Math::sin(angle)*length+@center_y]
  end
end

class FramerateCounter
  def initialize(color)
    @color = color
    @frames, @last_frames, @last_sec = 0, 0, 0
  end

  def capture_and_reset_framecount(new_second)
    @last_frames = @frames
    @frames = 0
    @last_sec = new_second
  end

  def update(time=nil)
    time ||= DateTime.now
    capture_and_reset_framecount time.second if time.second != @last_sec
    @frames += 1
  end

  def draw_on(surface, x, y)
    surface.font.draw("fps: %d" % [@last_frames], x, y, ZOrder::UI, 1.0, 1.0, @color)
  end
end

class ClockWindow < Gosu::Window
  attr_reader :center_x, :center_y, :font

  def initialize
    @width, @height = 640, 480
    @center_x, @center_y = @width / 2, @height / 2

    super @width, @height, false
    @frames, @last_frames, @last_sec = 0, 0, 0
    @font = Gosu::Font.new(self, 'courier', 20) # Gosu::default_font_name, 20)

    metrics_image = Gosu::Image.from_text(self, "fps: 60", 'courier', 20)

    @framerate_x = @width - (metrics_image.width+10)

    @clock = Clock.new @width, @height
    @framerate_counter = FramerateCounter.new 0xffffff00
  end

  def draw
    # background
    draw_quad 0,0,0xff000000,
              @width,0,0xff800000,
              @width,@height, 0xff008000,
              0,@height, 0xff000080,
              ZOrder::Background

    now = DateTime.now

    # art - draw a stoopid clock
    @clock.draw_label_on self, now
    @clock.draw_on self, now
    @framerate_counter.update

    # UI crap - framerate
    @framerate_counter.draw_on self, @framerate_x, 10
  end
end

ClockWindow.new.show
