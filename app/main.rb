require "app/root_scene"
require "app/game"
require "app/player"
require "app/scenes/level_scene"

def tick args
  $root_scene ||= RootScene.new
  $root_scene.args = args
  $root_scene.tick
end

def reset args
  $root_scene = nil
end

GTK.reset