  # Logical canvas width and height
  WIDTH = 1280
  HEIGHT = 720

  # Pixel art screen dimensions
  PIXEL_WIDTH = 320
  PIXEL_HEIGHT = 180

  # Determine best fit zoom level
  ZOOM_WIDTH = (WIDTH / PIXEL_WIDTH).floor
  ZOOM_HEIGHT = (HEIGHT / PIXEL_HEIGHT).floor
  ZOOM = [ZOOM_WIDTH, ZOOM_HEIGHT].min

  # Compute the offset to center the Nokia screen
  OFFSET_X = (WIDTH - PIXEL_WIDTH * ZOOM) / 2
  OFFSET_Y = (HEIGHT - PIXEL_HEIGHT * ZOOM) / 2

  # Compute the scaled dimensions of the Nokia screen
  ZOOMED_WIDTH = PIXEL_WIDTH * ZOOM
  ZOOMED_HEIGHT = PIXEL_HEIGHT * ZOOM

  def boot args
    args.state = {}
  end

  def tick args
    # set the background color to black
    args.outputs.background_color = [0, 0, 0]

    # define a render target that represents the pixel art canvas
    args.outputs[:pixel_canvas].w = PIXEL_WIDTH
    args.outputs[:pixel_canvas].h = PIXEL_HEIGHT
    args.outputs[:pixel_canvas].background_color = [199, 240, 216]

    # new up the game if it hasn't been created yet
    $game ||= Game.new

    # pass args environment to the game
    $game.args = args

    # compute the mouse position in the canvas
    $game.mouse_position = {
      x: (args.inputs.mouse.x - OFFSET_X).idiv(ZOOM),
      y: (args.inputs.mouse.y - OFFSET_Y).idiv(ZOOM),
      w: 1,
      h: 1,
    }

    # update the game
    $game.tick

    # render the game scaled to fit the screen
    args.outputs.sprites << {
      x: WIDTH / 2,
      y: HEIGHT / 2,
      w: ZOOMED_WIDTH,
      h: ZOOMED_HEIGHT,
      anchor_x: 0.5,
      anchor_y: 0.5,
      path: :pixel_canvas,
    }
  end

  # if GTK.reset is called
  # clear out the game so that it can be re-initialized
  def reset args
    $game = nil
  end
