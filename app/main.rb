require "app/scaler.rb"

BGCOLOUR = {r: 171, g: 194, b: 192}
FGCOLOUR = {r: 36, g: 23, b: 38}

class Game
  attr :args, :mouse_position

  def tick
    canvas.background_color = [BGCOLOUR.r, BGCOLOUR.g, BGCOLOUR.b]
  end

  def sm_label
    { x: 0, y: 0, size_px: 8, font: "fonts/quaver.ttf", anchor_x: 0, anchor_y: 0 }
  end

  def md_label
    { x: 0, y: 0, size_px: 16, font: "fonts/quaver.ttf", anchor_x: 0, anchor_y: 0 }
  end

  def lg_label
    { x: 0, y: 0, size_px: 24, font: "fonts/quaver.ttf", anchor_x: 0, anchor_y: 0 }
  end

  def xl_label
    { x: 0, y: 0, size_px: 32, font: "fonts/quaver.ttf", anchor_x: 0, anchor_y: 0 }
  end

  def canvas
    outputs[:pixel_canvas]
  end

  def outputs
    @args.outputs
  end

  def inputs
    @args.inputs
  end

  def state
    @args.state
  end
end

# GTK.reset will reset your entire game
# it's useful for debugging and starting fresh
# comment this line out if you want to retain your
# current game state in between hot reloads
GTK.reset
