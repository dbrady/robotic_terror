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
