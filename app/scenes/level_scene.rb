class LevelScene
  attr :game, :args, :player

  def initialize game
    @game = game
    @player = Player.new # maybe move back to Game? or use args.state?
  end

  # id for scene lookup
  def id
    :level_scene
  end

  def tick
    args.outputs.background_color = [0, 0, 0]

    args.outputs << player

    player.x = player.x.lerp(mouse_position.x, 0.1).clamp(player.w/2, 1280 - player.w/2)
  end

  def mouse_position
    args.inputs.mouse
  end

  def player
    @player
  end
end