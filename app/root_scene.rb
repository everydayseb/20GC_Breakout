class RootScene
  attr :args, :game

  def initialize
    @game = Game.new
    @level_scene = LevelScene.new @game
    @scenes = [@level_scene]
  end

  def defaults
    args.state.scene ||= :level_scene
  end

  def tick
    defaults

    scene_before_tick = args.state.scene

    scene = get_current_scene
    scene.args = args
    scene.tick

    if args.state.scene != scene_before_tick
      raise "Do not change the scene mid tick, set state.next_scene"
    end

    if args.state.next_scene
      args.state.scene = args.state.next_scene
      args.state.next_scene = nil
    end
  end

  def get_current_scene
    scene = @scenes.find { |scene| scene.id == args.state.scene }

    raise "Scene with id #{args.state.scene} does not exist." if !scene

    scene
  end
end