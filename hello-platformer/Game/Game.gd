extends Node2D

func _ready():
	pass


func generate():
	$World.clear()
	$World.generate()
	for x in range(14):
		$World.expand()
	$World.expand(true)
	
	$Player.position = Vector2(16, 0)
	$Player.protection = false


func _on_Player_finish() -> void:
	$Player/Camera2D/UI.continue_off()
	$Player/Camera2D/UI/Control/MenuButton.disabled = true
	$Player/Camera2D/UI/VBoxContainer.visible = true


func _on_UI_new_game() -> void:
	$Player/Camera2D/UI.continue_on()
	generate()
