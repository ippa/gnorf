class Block < GameObject
  traits :collision_detection, :velocity
  trait :bounding_box, :debug => false
  attr_reader :energy, :score
  
  def initialize(options = {})
    @image = Image["#{self.filename}.bmp"].dup

    super
    
    @energy = 100
    @score = 100
    self.zorder = 10
    cache_bounding_box
  end
  
  def hit_by(game_object)
    self.x += game_object.velocity_x / 4    
    Smokepuff.create(:x => self.x, :y => self.y)
    
    @energy -= game_object.energy
    if @energy < 0
      3.times { Smokepuff.create(:x => self.x+rand(4), :y => self.y+rand(4)) }
      game_state.game_object_map.clear_game_object(self)
      destroy
      $window.score += @score
    end
  end

  def move(x, y)
    self.x += x
    
    self.y += y    
    game_state.game_object_map.each_collision(self) do |game_object|
      self.y = previous_y
      self.velocity_y = 0
    end 
    
    if self.y != self.previous_y
      game_state.game_object_map.delete(self)
      game_state.game_object_map.insert(self)
    end
  end
  
  def draw
    super
    Image["stonewall_crack1.bmp"].draw_rot(self.bb.left, self.bb.bottom, self.zorder+1,0,0,factor,factor) if @energy < 80
    Image["stonewall_crack2.bmp"].draw_rot(self.bb.left, self.bb.bottom, self.zorder+1,0,0,factor,factor) if @energy < 40
  end
  
  def update
    move(0, game_state.grid.last)  # Blocks fall down grid by grid
  end
end

class StonewallGun < Block
  def setup; @energy = 50; @score = 50; end  
  
  def attack
    Bullet.create(:x => x, :y => y+8, :velocity_x => -5-rand(5), :velocity_y => -rand(5))
  end
end

class StonewallMortar < Block
  def setup; @energy = 50; @score = 50; end  
  
  def attack
    Bomb.create(:x => x, :y => y+8, :velocity_x => -2-rand(5), :velocity_y => -5-rand(5))
  end
end

class Stonewall < Block
  def setup; @energy = 80; @score = 80; end  
end
class StonewallWindow < Block
  def setup; @energy = 60; @score = 60; end
end
class StonewallArch < Block
  def setup; @energy = 120; @score = 120; end
end
class Tower < Block
  def setup; @energy = 30; @score = 30; end
end
class Gate < Block
  def setup; @energy = 150; @score = 150; end
end
class StonewallRoof < Block
  def setup; @energy = 20; @score = 20; end
end


class StonewallCrack < GameObject
  trait :bounding_box
  
  def setup
    @image = Image["#{self.filename}.bmp"]
    self.zorder = 110
  end
end  

class StonewallCrack1 < StonewallCrack; end
class StonewallCrack2 < StonewallCrack; end
