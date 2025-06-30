require "app/scaler.rb"

BGCOLOUR = {r: 171, g: 194, b: 192}
FGCOLOUR = {r: 36, g: 23, b: 38}

class Game
  attr :args, :mouse_position

  def tick
    #GTK.slowmo! 4
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
    GTK.set_mouse_grab 0
    # TODO: main menu scene
  end

  def tick_game_scene
    #GTK.set_mouse_grab 2
    defaults
    create_player_sprite
    render
    calc_player
    calc_bricks
    calc_ball
  end

  def tick_game_over_scene
    GTK.set_mouse_grab 0
    # TODO: lose and restart scene
  end

  def defaults
    WALL_WIDTH ||= 3
    SIDE_WALL ||= {y: 3, w: WALL_WIDTH, h: PIXEL_HEIGHT - WALL_WIDTH * 2, **FGCOLOUR}
    state.walls ||= [SIDE_WALL.merge(x: WALL_WIDTH), SIDE_WALL.merge(x: PIXEL_WIDTH - 6)]
    state.ceiling ||= {x: WALL_WIDTH, y: PIXEL_HEIGHT - 6, w: PIXEL_WIDTH - 6, h: WALL_WIDTH, **FGCOLOUR}
    state.player ||= {
      x: PIXEL_WIDTH / 2, y: 12, 
      w: 32, h: 12, 
      path: :player_group, 
      anchor_x: 0.5, 
      anchor_y: 0.5, 
      **FGCOLOUR,
      lives: 3
    }
    state.bricks ||= []
    state.ball ||= {
      x: PIXEL_WIDTH / 2, y: 40,
      w: 4, h: 4,
      path: 'sprites/ball.png',
      anchor_x: 0.5, anchor_y: 0.5,
      **FGCOLOUR, 
      dx: 0, dy: -1, 
      speedx: 0, speedy: -2, 
      bounces: 0,
    }
    state.level_loaded ||= false
    state.ball_in_play ||= false
    state.sfx ||= {blip: 'sounds/blip.wav', paddle: 'sounds/c.wav',
                  bounce: ['sounds/c.wav', 'sounds/d.wav', 'sounds/e.wav', 
                          'sounds/f.wav', 'sounds/g.wav', 'sounds/a.wav', 
                          'sounds/b.wav', 'sounds/c2.wav', 'sounds/d2.wav', 
                          'sounds/e2.wav', 'sounds/f2.wav', 'sounds/g2.wav', 
                          'sounds/a2.wav', 'sounds/b2.wav', 'sounds/c2.wav'],}
  end

  def render
    canvas.sprites << state.ceiling
    canvas.sprites << state.walls
    canvas.sprites << state.player
    canvas.sprites << state.bricks
    canvas.sprites << state.ball

    args.outputs.watch "FPS: #{GTK.current_framerate.to_sf}"
    args.outputs.watch "Number of bricks #{state.bricks.length}"
    args.outputs.watch "Number of bounces: #{state.ball.bounces}"
  end

  def calc_player
    if !state.ball_in_play
      if inputs.mouse.buttons.left.click
        state.ball_in_play = true 
        outputs.sounds << state.sfx[:blip]
      end
    end
    state.player.x = state.player.x.lerp(mouse_position.x, 0.1).clamp(6 + state.player.w/2, PIXEL_WIDTH - 6 - state.player.w/2)
  end

  def calc_bricks
    # generate bricks if new game and there are none
    # destroy any bricks flagged :destroy, play effects
    
    generate_bricks if !state.level_loaded

    # destroy bricks
    state.bricks.reject! {|brick| brick.destroyed}
  end

  def generate_bricks
    return if state.level_loaded
    MAX_COLUMNS ||= 9
    MAX_ROWS ||= 8
    X_OFFSET ||= 12
    Y_OFFSET ||= 81
    column ||= 0
    row ||= 0

    while row < MAX_ROWS
      while column < MAX_COLUMNS
        state.bricks << brick_prefab.merge(x: 33 * column + X_OFFSET, y: 11 * row + Y_OFFSET)
        column += 1
      end
      column = 0
      row += 1
    end

    state.level_loaded = true
  end

  def calc_ball
    return unless state.ball_in_play

    state.ball.x += state.ball.speedx
    state.ball.y += state.ball.speedy

    state.walls.each do |wall|
      if state.ball.intersect_rect? wall
        state.ball.speedx *= -1

        state.ball.bounces += 1

        play_bounce_sfx

      end
    end

    if state.ball.intersect_rect? state.ceiling
      state.ball.speedy *= -1

      state.ball.bounces += 1

      play_bounce_sfx
    end

    if state.ball.intersect_rect? state.player
      #increase the reflection towards the edges of the paddle
      state.ball.speedx += -((state.ball.x - state.player.x) * 0.1) * -1
      state.ball.speedy *= -1

      #reset bounce bounter (for selecting sfx)
      state.ball.bounces = 0

      play_bounce_sfx
    end

    state.bricks.each do |brick|
      if state.ball.intersect_rect? brick

        state.ball.bounces += 1

        play_bounce_sfx

        brick.destroyed = true

        if state.ball.y <= brick.y || state.ball.y >= brick.y + brick.h
          state.ball.speedy *= -1
        else
          state.ball.speedx *= -1
        end
      end
    end

    if state.ball.y + state.ball.h < 0 
      state.ball_in_play = false
      state.ball = {
        x: PIXEL_WIDTH / 2, y: 40,
        w: 4, h: 4,
        path: 'sprites/ball.png',
        anchor_x: 0.5, anchor_y: 0.5,
        **FGCOLOUR, 
        dx: 0, dy: -1, 
        speedx: 0, speedy: -2, 
        bounces: 0,
      }

      state.player.lives -= 1 unless state.player.lives == 0
    end

  end

  def create_player_sprite    
    # create player sprite
    canvas[:player_group].w = 32
    canvas[:player_group].h = 12

    canvas[:player_group].background_color = [0, 0, 0, 0]

    number_of_lives =  state.player.lives

    life_sprites ||= Array.new(number_of_lives)

    life_sprites.map!.with_index do |sprite, i|
      sprite = { 
        x: 3 * i,
        y: 0,
        w: 2, h: 2,
        path: :solid,
        **FGCOLOUR
      }
    end

    canvas[:player_group] << life_sprites

    canvas[:player_group] << {
      x: 0, y: 4, 
      w: 32, h: 6, 
      path: :solid,
      **FGCOLOUR,
      lives: 3
    }

  end

  def brick_prefab
    { x: 0, y: 0, w: 32, h: 10, path: :solid, **FGCOLOUR }
  end

  def play_bounce_sfx
    outputs.sounds << current_bounce_sfx
  end

  def current_bounce_sfx
    num_of_bounces = state.ball.bounces.clamp(0, state.sfx.bounce.length - 1)
    state.sfx.bounce[num_of_bounces]
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
