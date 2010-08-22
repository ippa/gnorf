class Terrain < GameObject
  traits :collision_detection
  trait :bounding_box, :debug => false
  
  def setup
    @image = Image["#{self.filename}.bmp"].dup
    cache_bounding_box
  end
end
class Grass < Terrain; end
class Floor < Terrain; end


class Decoration < GameObject
  traits :bounding_box
  
  def setup
    @image = Image["#{self.filename}.bmp"].dup
  end
end
class Flower < Decoration; end
class Skull < Decoration; end
class Bone < Decoration; end