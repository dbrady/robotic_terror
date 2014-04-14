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
      x1, y1 = hand_endpoints ticks_to_degrees(min, 60), @minute_ticks.first
      x2, y2 = hand_endpoints ticks_to_degrees(min, 60), @minute_ticks.last
      surface.draw_line x1, y1, @face_color, x2, y2, @face_color, ZOrder::ClockFace
    end

    12.times do |hr|
      x1, y1 = hand_endpoints ticks_to_degrees(hr, 12), @hour_ticks.first
      x2, y2 = hand_endpoints ticks_to_degrees(hr, 12), @hour_ticks.last
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

  def ticks_to_degrees(ticks, ticks_per_revolution)
    ticks*360.0/ticks_per_revolution-90
  end

  def draw_hand_on(surface, angle, length, color)
    x, y = hand_endpoints angle, length
    surface.draw_line @center_x, @center_y, color, x, y, color, ZOrder::ClockHands
  end

  def draw_second_hand_on(surface, second)
    draw_hand_on surface, ticks_to_degrees(second, 60), @second_length, @second_color
  end

  def draw_minute_hand_on(surface, minute)
    draw_hand_on surface, ticks_to_degrees(minute, 60), @minute_length, @minute_color
  end

  def draw_hour_hand_on(surface, hour)
    draw_hand_on surface, ticks_to_degrees(hour, 12), @hour_length, @hour_color
  end

  def hand_endpoints(degrees, length)
    [Math::cos(Math::PI*degrees/180.0)*length+@center_x, Math::sin(Math::PI*degrees/180.0)*length+@center_y]
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

    @clock = Clock.new @width, @height
  end

  def capture_and_reset_framecount(new_second)
    @last_frames = @frames
    @frames = 0
    @last_sec = new_second
  end


  def draw
    # background
    draw_quad 0,0,0xff000000,
              @width,0,0xff800000,
              @width,@height, 0xff008000,
              0,@height, 0xff000080,
              ZOrder::Background

    # framerate
    now = DateTime.now

    capture_and_reset_framecount(now.second) if @last_sec != now.second
    @frames += 1
    @font.draw("fps: %d" % [@last_frames], 540, 10, ZOrder::UI, 1.0, 1.0, 0xffffff00)

    # art - draw a stoopid clock
    @clock.draw_label_on self, now
    @clock.draw_on self, now
  end
end

ClockWindow.new.show
