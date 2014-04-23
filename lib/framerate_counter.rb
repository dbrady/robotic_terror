require 'time'

class FramerateCounter
  attr_reader :z

  def initialize(color,z=0)
    @color, @z = color, z
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
    surface.font.draw("fps: %d" % [@last_frames], x, y, z, 1.0, 1.0, @color)
  end
end
