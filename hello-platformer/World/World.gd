extends Node2D

onready var map = $TileMap
onready var portal = $CPUParticles2D

const WORLD_POSITION = Vector2(0, 35)
const WORLD_SIZE = Vector2(21, 2)

var rng = RandomNumberGenerator.new()

const SMALL_RISE_CHANCE = 0.1
const CLIFF_CHANCE = 0.008

const GRASS_CHANCE = 0.3
const MUSHROOM_CHANCE = 0.4
const TREE_CHANCE = 0.15

const GRUB_CHANCE = 0.3

const NUBE_CHANCE = 0.6

const DEFAULT_BACKGROUD_COLOR = Color("#fcdfcd")

var world_start = Vector2(0, 0)
var world_end = Vector2(0, 0)

var grub_sceene = preload("res://Units/Grub/Grub.tscn")


func _ready():
	rng.randomize()
	
	clear()
	
	generate(WORLD_SIZE, WORLD_POSITION, true)
	expand(true)



func clear():
	if get_tree().has_group("npc"):
		for npc in get_tree().get_nodes_in_group('npc'):
			if npc.has_method('queue_free'):
				npc.queue_free()
	
	portal.emitting = false
	map.clear()
	VisualServer.set_default_clear_color(DEFAULT_BACKGROUD_COLOR)


func generate(
	world_size:Vector2=WORLD_SIZE,
	world_position:Vector2=WORLD_POSITION,
	start=false
):
	_generate_world(world_size, world_position, start)


func expand(
	end:bool=false, 
	world_size:Vector2=WORLD_SIZE, 
	world_position:Vector2=world_end
):
	_generate_world(world_size, world_position)
	
	if end:
		_generate_end()


func _generate_end():
	portal.position = map.map_to_world(world_end)-Vector2(8,8)
	portal.emitting = true


func _generate_world(
	world_size:Vector2=WORLD_SIZE,
	world_position:Vector2=WORLD_POSITION,
	start=false
):
	_generate_map(world_size, world_position, start)
	_spawn_npc(world_size, world_position)


func _spawn_npc(
	world_size: Vector2,
	world_position: Vector2
) -> void:
	var rand: float
	
	for x in range(world_size.x):
		if x % 5 != 0:
			continue
		
		rand = rng.randf()
		print(rand)
		
		if rand < GRUB_CHANCE:
			print("Grub...")
			var grub = grub_sceene.instance()
			grub.add_to_group("npc")
			grub.position = map.map_to_world(world_position+Vector2(x,world_size.y - 50))
			add_child(grub)
	
	print(get_tree().get_nodes_in_group("npc"))


func _generate_map(
	world_size: Vector2, 
	world_position: Vector2,
	start: bool
):
	_generate_main_ground(world_size, world_position, start)
	_generate_vegetation(world_size, world_position)
	_generate_nubes(world_size, world_position)


func _generate_nubes(world_size, world_position):
	var rand: float
	var vegetation_id: int = 3
	
	for x in range(world_size.x):
		rand = rng.randf()
		print(rand)
		
		if rand < NUBE_CHANCE:
			var rise_y = 0
			while map.get_cellv(world_position+Vector2(x,rise_y-1)) != -1:
				rise_y -= 1
			map.set_cellv(world_position+Vector2(x,rise_y-rng.randi_range(3,9)), rng.randi_range(11,12))
			
			


func _generate_vegetation(
	world_size: Vector2, 
	world_position: Vector2
):
	var rand: float
	var vegetation_id: int = 3
	
	for x in range(world_size.x):
		rand = rng.randf()
		print(rand)
		
		if rand < TREE_CHANCE and vegetation_id != 9:
			vegetation_id = 9
			
			var tree_h = rng.randi_range(2,7)
			
			if map.get_cellv(world_position+Vector2(x,0)) == 1:
				if map.get_cellv(world_position+Vector2(x,-1)) == -1:
					for y in range(tree_h):
						map.set_cellv(world_position+Vector2(x,-1-y), vegetation_id)
				else:
					var rise_y = 0
					while map.get_cellv(world_position+Vector2(x,rise_y-1)) != -1:
						rise_y -= 1
					for y in range(tree_h):
						map.set_cellv(world_position+Vector2(x,rise_y-y-1), vegetation_id)
				map.update_bitmask_region(world_position+Vector2(x,-1), world_position+Vector2(x,-1-tree_h))
			
			
			continue
		elif rand < GRASS_CHANCE:
			vegetation_id = rng.randi_range(3,6)
		elif rand < MUSHROOM_CHANCE:
			vegetation_id = rng.randi_range(7, 8)
		else:
			continue
			
		if map.get_cellv(world_position+Vector2(x,0)) == 1:
			if map.get_cellv(world_position+Vector2(x,-1)) == -1:
				map.set_cellv(world_position+Vector2(x,-1), vegetation_id)
			else:
				var rise_y = 0
				while map.get_cellv(world_position+Vector2(x,rise_y-1)) != -1:
					rise_y -= 1
				map.set_cellv(world_position+Vector2(x,rise_y-1), vegetation_id)


func _generate_main_ground(
	world_size: Vector2,
	world_position: Vector2,
	start: bool
):
	var rand: float
	
	var rise_width: int = 0
	var rise_height: int = 0
	
	var cliff_width: int = 0
	
	if start:
		world_start = world_position
	
	for x in range(world_size.x):
		# Generating a floor
		map.set_cellv(world_position+Vector2(x,0), 1)
		map.set_cellv(world_position+Vector2(x,1), 1)
		
		# Making a starting space for the player
		if x < 10 and start:
			continue
		
		# Make a cliff, if there is one
		if cliff_width:
			map.set_cellv(world_position+Vector2(x,1), -1)
			for rise_y in range(rise_height+1):
				map.set_cellv(world_position+Vector2(x, -rise_y), -1)
				cliff_width -= 1
			continue
		
		# Make a rise, if there is one
		if rise_width:
			map.set_cellv(world_position+Vector2(x, -rise_height), 1)
			for rise_y in range(rise_height):
				map.set_cellv(world_position+Vector2(x, -rise_y), 1)
			
			rise_width -= 1
			
			# Make a rise on the rise (at least two cells wide)
			if rise_width>1 and rng.randi_range(0,1):
				var h = rng.randi_range(1,3)
				map.set_cellv(world_position+Vector2(x, -(rise_height+h)), 1)
				for rise_y in range(rise_height+h):
					map.set_cellv(world_position+Vector2(x, -rise_y), 1)
				
				map.set_cellv(world_position+Vector2(x+1, -(rise_height+h)), 1)
				for rise_y in range(rise_height+h):
					map.set_cellv(world_position+Vector2(x+1, -rise_y), 1)
				map.set_cellv(world_position+Vector2(x+1,1), 1)
				
			continue
		
		rand = rng.randf()
		print(rand)
		
		if rand < CLIFF_CHANCE:
			cliff_width = rng.randi_range(1, 10)
			print("Cliff. Width=", cliff_width)
		elif rand < SMALL_RISE_CHANCE and x < world_size.x-1:
			rise_width = int( rand * 100) % 10
			rise_height = int( rand * 1000) % 10
			
			if rise_height > 4:
				rise_height -= 5
			
			if rise_width < 2:
				rise_width = 2
			
			print("Rise. Width=", rise_width, " Height=", rise_height)
	
	map.set_cellv(world_position+Vector2(world_size.x,0), 1)
	map.set_cellv(world_position+Vector2(world_size.x,1), 1)
	
	map.update_bitmask_region()
	
	world_end = world_position + Vector2(world_size.x+1,0)
	
#	map.set_cellv(world_end+Vector2(0,-1), 0)
#	map.set_cellv(world_end+Vector2(0,-2), 0)
#	map.set_cellv(world_end+Vector2(0,-3), 0)
#	map.set_cellv(world_end+Vector2(0,-4), 0)
#	map.set_cellv(world_end+Vector2(0,-5), 0)
	
