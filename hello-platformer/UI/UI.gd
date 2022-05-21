extends Control

signal menu_button
signal continue_game
signal new_game

func _ready():
	pass


func continue_on():
	$VBoxContainer/ContinueButton.disabled = false

func continue_off():
	$VBoxContainer/ContinueButton.disabled = true


func _on_MenuButton_pressed() -> void:
	$Control/MenuButton.disabled = true
	$VBoxContainer.visible = true
	emit_signal("menu_button")


func _on_ContinueButton_pressed() -> void:
	$Control/MenuButton.disabled = false
	$VBoxContainer.visible = false
	$TextEdit.visible = false
	emit_signal("continue_game")


func _on_NewGameButton_pressed() -> void:
	$Control/MenuButton.disabled = false
	$VBoxContainer.visible = false
	$TextEdit.visible = false
	emit_signal("new_game")


func _on_AuthorsButton_pressed() -> void:
	$TextEdit.visible = not $TextEdit.visible
