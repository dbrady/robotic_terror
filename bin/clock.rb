require 'gosu'
require 'time'

module ZOrder
  Background, ClockFace, ClockHands, UI = *0..3
end

class Clock
  def draw_time_on(time, surface)
    hour, minute, second = time.hour, time.minute, time.second

    # draw clock face
    60.times do |min|
      x1, y1 = hand_endpoints minutes_to_degrees(min), @minute_ticks.first
      x2, y2 = hand_endpoints minutes_to_degrees(min), @minute_ticks.last
      surface.draw_line x1, y1, @face_color, x2, y2, @face_color, ZOrder::ClockFace
    end

    12.times do |hr|
      x1, y1 = hand_endpoints hours_to_degrees(hr), @hour_ticks.first
      x2, y2 = hand_endpoints hours_to_degrees(hr), @hour_ticks.last
      surface.draw_line x1, y1, @face_color, x2, y2, @face_color, ZOrder::ClockFace
    end

    # draw clock hands
    second += time.second_fraction
    minute += second/60.0
    hour += minute/60.0

    second_x, second_y = hand_endpoints seconds_to_degrees(second), @second_length
    hour_x, hour_y = hand_endpoints hours_to_degrees(hour), @hour_length
    minute_x, minute_y = hand_endpoints minutes_to_degrees(minute), @minute_length


    surface.draw_line @center_x, @center_y, @second_color, second_x, second_y, @second_color, ZOrder::ClockHands
    surface.draw_line @center_x, @center_y, @minute_color, minute_x, minute_y, @minute_color, ZOrder::ClockHands
    surface.draw_line @center_x, @center_y, @hour_color, hour_x, hour_y, @hour_color, ZOrder::ClockHands
  end

  def hand_endpoints(degrees, length)
    [Math::cos(Math::PI*degrees/180.0)*length+@center_x, Math::sin(Math::PI*degrees/180.0)*length+@center_y]
  end

  def seconds_to_degrees(second)
    second*360/60.0-90
  end

  def minutes_to_degrees(minute)
    minute*360/60.0-90
  end

  def hours_to_degrees(hour)
    hour*360/12.0-90
  end
end

class ClockWindow < Gosu::Window
  def initialize
    @size_x, @size_y = 640, 480
    @center_x, @center_y = @size_x / 2, @size_y / 2

    super @size_x, @size_y, false
    @frames, @last_frames, @last_sec = 0, 0, 0
    @font = Gosu::Font.new(self, 'courier', 20) # Gosu::default_font_name, 20)
    # $stderr.puts Gosu::default_font_name

    @second_length = @center_y * 0.8
    @minute_length = @center_y * 0.7
    @hour_length = @center_y * 0.5

    @hour_ticks = [0.81, 0.99].map {|t| t*@center_y}
    @minute_ticks = [0.9, 0.99].map {|t| t*@center_y}

    @second_color, @minute_color, @hour_color, @face_color = 0xffff0000, 0xff0000ff, 0xff00ff00, 0xffffffff
    @clock = Clock.new
  end

  def draw
    # background
    draw_quad 0,0,0xff000000,
              @size_x,0,0xff800000,
              @size_x,@size_y, 0xff008000,
              0,@size_y, 0xff000080,
              ZOrder::Background

    # framerate
    now = DateTime.now

    if @last_sec != now.second
      @last_frames = @frames
      @frames = 0
      @last_sec = now.second
    end
    @frames += 1
    @font.draw("Time: %2d:%02d:%02d fps: %d" % [now.hour, now.minute, now.second, @last_frames], 10, 10, ZOrder::UI, 1.0, 1.0, 0xffffff00)

    # art - draw a stoopid clock
    @clock.draw_time_on now, self
  end
end

ClockWindow.new.show
