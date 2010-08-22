class Weapon < Enemy
  trait :animation

  def setup
    super
    self.acceleration_y = 0.2
  end

  def bounce
    self.stop
    self.y = game_state.floor_y
  end  
end

class Fireball < Weapon
  
  def setup
    super
    @energy = 80
  end
  
  def explode
    Smokepuff.create(:x => x, :y => y, :color => Color::RED.dup, :scale => 1)
    destroy
  end
  
end

class Bullet < Weapon
  trait :animation
  
  def setup
    super
    @energy = 30
  end
  
  def explode
    Smokepuff.create(:x => x, :y => y, :scale => 1)
    destroy
  end
end


class Bomb < Weapon
  trait :animation
  
  def setup
    super
    after(5000 + rand(2000)) { explode }
    @energy = 50
  end
  
  def explode
    Smokepuff.create(:x => x, :y => y, :color => Color::RED.dup, :scale => 3)
    Smokepuff.create(:x => x, :y => y, :color => Color::YELLOW.dup, :scale => 3)
    destroy
  end  
end