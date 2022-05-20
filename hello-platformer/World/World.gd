extends Node2D

onready var map = $TileMap

var rng = RandomNumberGenerator.new()

const SMALL_RISE_CHANCE = 0.1


func _ready():
	rng.randomize()
	
	map.clear()
	
	_generate_world()


func _generate_world(world_size:Vector2=Vector2(60,2), world_position:Vector2=Vector2(0,35)):
	_generate_map(world_size, world_position)


func _generate_map(world_size: Vector2, world_position: Vector2):
	_generate_main_ground(world_size, world_position)


func _generate_main_ground(world_size: Vector2, world_position: Vector2):
	var rand: float
	
	var rise_width: int = 0
	var rise_height: int = 0
	
	for x in range(world_size.x):
		# Generating a floor
		map.set_cellv(world_position+Vector2(x,0), 1)
		map.set_cellv(world_position+Vector2(x,1), 1)
		
		# Making a starting space for the player
		if x < 10:
			continue
		
		if rise_width:
			map.set_cellv(world_position+Vector2(x, -rise_height), 1)
			for rise_y in range(rise_height):
				map.set_cellv(world_position+Vector2(x, -rise_y), 1)
			
			rise_width -= 1
			continue
		
		rand = rng.randf()
		print(rand)
		
		if rand < SMALL_RISE_CHANCE:
			rise_width = int( rand * 100) % 10
			rise_height = int( rand * 1000) % 10
			
			if rise_height > 4:
				rise_height -= 5
			
			if rise_width < 2:
				rise_width = 2
	
	map.update_bitmask_region()
	
