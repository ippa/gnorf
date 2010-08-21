class Effect < GameObject
  trait :velocity

  def setup
    self.velocity = 1.0-rand*2, 1.0-rand*2
    @alpha_velocity = 4 + rand(2)
    @angle_velocity = rand(4)
    @scale_velocity = rand/10
    update
  end
  
  def update
    self.image = animation.next
    self.alpha -= @alpha_velocity
    self.angle += @angle_velocity
    self.factor += @scale_velocity
    destroy if self.alpha == 0
  end
end


class Smokepuff < Effect
  trait :animation, :delay => 150, :loop => false  
end