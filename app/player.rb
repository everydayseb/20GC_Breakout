class Player
  attr_sprite
  attr :args

  def initialize
    @args = args
    @x = Grid.w / 2
    @y = 60
    @w = 192
    @h = 16
    @anchor_x = 0.5
    @anchor_y = 0.5
  end
end