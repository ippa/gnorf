class Weapon < Enemy
  trait :animation
  attr_reader :energy
  
  def setup
    super
    self.acceleration_y = 0.2
  end

  def bounce
    self.velocity_x = self.velocity_x / 2
    self.velocity_y = -self.velocity_y / 2
    self.y = game_state.floor_y
  end
  
  def move(x, y)
    return if grabbed?
    
    self.x += x
    self.y += y    
  end
end

class Fireball < Weapon
  def setup
    super
    @energy = 20
  end

  def explode
    Smokepuff.create(:x => x, :y => y, :color => Color::RED.dup, :scale => 1)
    destroy
  end
end

class Bullet < Weapon  
  def setup
    super
    @energy = 10
  end
      
  def explode
    Smokepuff.create(:x => x, :y => y, :scale => 1)
    destroy
  end
end


class Bomb < Weapon
  def setup
    super
    after(5000 + rand(2000)) { explode }
    @energy = 30
  end
  
  def explode
    Smokepuff.create(:x => x, :y => y, :color => Color::RED.dup, :scale => 3)
    Smokepuff.create(:x => x, :y => y, :color => Color::YELLOW.dup, :scale => 3)
    destroy
  end  
end