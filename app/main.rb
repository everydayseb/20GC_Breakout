require "app/scaler.rb"

BGCOLOUR = {r: 171, g: 194, b: 192}
FGCOLOUR = {r: 36, g: 23, b: 38}

class Game
  attr :args, :mouse_position

  def tick
    canvas.background_color = [BGCOLOUR.r, BGCOLOUR.g, BGCOLOUR.b]
    state.current_scene ||= :game_scene
    # capture the current scene to verify it didn't change through
    # the duration of tick
    current_scene = state.current_scene

    # tick whichever scene is current
    case current_scene
    when :title_scene
      tick_title_scene
    when :game_scene
      tick_game_scene
    when :game_over_scene
      tick_game_over_scene
    end

    # make sure that the current_scene flag wasn't set mid tick
    if state.current_scene != current_scene
      raise "Scene was changed incorrectly. Set state.next_scene to change scenes."
    end

    # if next scene was set/requested, then transition the current scene to the next scene
    if state.next_scene
      state.current_scene = state.next_scene
      state.next_scene = nil
    end
  end

  def tick_title_scene
    # TODO: main menu scene
  end

  def tick_game_scene
    defaults
    render
    calc_player
  end

  def tick_game_over_scene
    # TODO: lose and restart scene
  end

  def defaults
    WALL_WIDTH ||= 3
    SIDE_WALL ||= {y: 0, w: WALL_WIDTH, h: PIXEL_HEIGHT - WALL_WIDTH, **FGCOLOUR}
    CEILING ||= {x: WALL_WIDTH, y: PIXEL_HEIGHT - 6, w: PIXEL_WIDTH - 6, h: WALL_WIDTH, **FGCOLOUR}
    state.walls ||= [SIDE_WALL.merge(x: WALL_WIDTH), SIDE_WALL.merge(x: PIXEL_WIDTH - 6), CEILING]
    state.player ||= {x: PIXEL_WIDTH / 2, y: 12, w: 32, h: 6, path: :solid, anchor_x: 0.5, anchor_y: 0.5, **FGCOLOUR}
  end

  def render
    canvas.sprites << state.walls
    canvas.sprites << state.player
  end

  def calc_player
    state.player.x = state.player.x.lerp(mouse_position.x, 0.1).clamp(6 + state.player.w/2, PIXEL_WIDTH - 6 - state.player.w/2)
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
