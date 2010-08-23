class Block < GameObject
  traits :collision_detection, :velocity
  trait :bounding_box, :debug => false
  attr_reader :energy, :score
  
  def initialize(options = {})
    @image = Image["#{self.filename}.bmp"].dup
    @energy, @score = 100, 100

    super
    
    self.zorder = 10
    cache_bounding_box
  end
  
  def hit_by(game_object)
    self.x += game_object.velocity_x / 4    
    Smokepuff.create(:x => self.x, :y => self.y)
    
    @energy -= game_object.energy
    Sound["explosion.wav"].play(0.2)
    
    if @energy < 0
      3.times { Smokepuff.create(:x => self.x+rand(4), :y => self.y+rand(4)) }
      game_state.game_object_map.clear_game_object(self)
      destroy
      $window.score += @score
      Sound["explosion.wav"].play(0.3)
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
    Image["stonewall_crack1.bmp"].draw_rot(self.bb.left, self.bb.bottom, self.zorder+1,0,0,factor,factor) if @energy < @score/1.2
    Image["stonewall_crack2.bmp"].draw_rot(self.bb.left, self.bb.bottom, self.zorder+1,0,0,factor,factor) if @energy < @score/1.5
  end
  
  def update
    move(0, game_state.grid.last)  # Blocks fall down grid by grid
  end
end

class StonewallGun < Block
  def setup; @energy, @score = 50, 50; end  
  
  def attack
    Bullet.create(:x => x, :y => y+8, :velocity_x => -5-rand(5), :velocity_y => -rand(5))
  end
end

class StonewallMortar < Block
  def setup; @energy, @score = 50, 50; end  
  
  def attack
    Bomb.create(:x => x, :y => y+8, :velocity_x => -2-rand(5), :velocity_y => -5-rand(5))
  end
end

class Stonewall < Block
  def setup; @energy, @score = 70, 70; end  
end
class StonewallWindow < Block
  def setup; @energy, @score = 30, 30; end
end
class StonewallArch < Block
  def setup; @energy, @score = 50, 50; end
end
class Tower < Block
  def setup; @energy, @score = 30, 30; end
end
class Gate < Block
  def setup; @energy, @score = 150,150; end
end
class StonewallRoof < Block
  def setup; @energy, @score = 20, 20; end
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
