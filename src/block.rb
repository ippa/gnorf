class Block < GameObject
  traits :collision_detection, :velocity
  trait :bounding_box, :debug => false
  
  def setup
    @image = Image["#{self.filename}.bmp"]
    @energy = 100
    self.zorder = 10
  end
  
  def hit_by(game_object)
    self.x += game_object.velocity_x / 4
    
    Smokepuff.create(:x => self.x, :y => self.y)
    
    @energy -= 33   if game_object.is_a? Knight
    @energy -= 55   if game_object.is_a? Horse
    @energy -= 100  if game_object.is_a? Balloon
    if @energy < 0
      3.times { Smokepuff.create(:x => self.x+rand(4), :y => self.y+rand(4)) }
      game_state.game_object_map.clear_game_object(self)
      destroy
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
    Image["stonewall_crack1.bmp"].draw_rot(self.x,self.y,self.zorder+1,1,0.5,factor,factor) if @energy < 80
    Image["stonewall_crack2.bmp"].draw_rot(self.x,self.y,self.zorder+1,1,0.5,factor,factor) if @energy < 40
  end
  
  def update
    move(0, game_state.grid.last)  # Blocks fall down grid by grid
  end
end

class Stonewall < Block; end
class StonewallWindow < Block; end
class StonewallRoof < Block; end
class StonewallArch < Block; end
class Gate < Block; end
class Tower < Block; end

class Crack < GameObject
  trait :bounding_box
  
  def setup
    @image = Image["#{self.filename}.bmp"]
    self.zorder = 110
  end
end  

class StonewallCrack1 < Crack; end
class StonewallCrack2 < Crack; end
