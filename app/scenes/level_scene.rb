class LevelScene
  attr :game, :args

  def initialize game
    @game = game
  end

  # id for scene lookup
  def id
    :level_scene
  end

  def tick
    args.outputs.background_color = [0, 0, 0]

    args.outputs << @game.player
  end
end