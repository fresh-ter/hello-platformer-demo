extends KinematicBody2D

const gravityPower = 10
const jumpPower = 20
const movementSpeed = 20

var gravity = 0

onready var sprite = $AnimatedSprite
onready var timer = $Timer

var right_direction = true

var rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready():
	rng.randomize()
	
	timer.wait_time = rng.randi_range(5, 14)
	timer.start()
	print(timer.wait_time)
	
	if rng.randi_range(0,1):
		_change_direction()


func _physics_process(delta: float) -> void:
	_applyGravity()
	
	if position.y > 600:
		queue_free()
		print(name, " end")
	elif position.y < -50:
		_change_direction()
	elif position.y < -150:
		queue_free()
		print(name, " end")
	
	if is_on_wall():
		_jump()
	
	if right_direction:
		move_and_slide(Vector2(movementSpeed, gravity), Vector2(0, -1))
	else:
		move_and_slide(Vector2(-movementSpeed, gravity), Vector2(0, -1))
	
	sprite.scale = sprite.scale.linear_interpolate(Vector2(1, 1), delta * 8)
	
	
func _change_direction() -> void:
	right_direction = not right_direction
	sprite.flip_h = not sprite.flip_h


func _jump() -> void:
	gravity = -jumpPower  * 10
	sprite.scale = Vector2(0.5, 1.5)


func _applyGravity() -> void:
	gravity += gravityPower
	
	if gravity > 0 and is_on_floor():
		gravity = 10



func _on_Timer_timeout() -> void:
	_change_direction()
