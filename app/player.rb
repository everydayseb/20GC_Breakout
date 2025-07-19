class Player
  attr_sprite
  attr :args
  attr :x

  def initialize
    @args = args
    @x = Grid.w / 2
    @y = 60
    @w = 192
    @h = 16
    @path = :solid
    @anchor_x = 0.5
    @anchor_y = 0.5
  end

  def serialize
    {x:self.x, y:self.y, w:self.w, h:self.h, path:self.path}
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end
end