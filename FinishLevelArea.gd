extends Area2D

@onready var player = $"../Player"
@onready var finished_level_menu = $"../FinishedLevelMenu"

@onready var plane_sprite = $Sprite2D
@onready var plane_normal = preload("res://kenney_assets/EndLevel.png")
@onready var plane_activate = preload("res://kenney_assets/EndLevelActivate.png")

var has_player_entered = false

func _process(delta):
	if has_player_entered:
		if Input.is_action_just_pressed("finish_level"):
			get_tree().paused = true
			Input.set_custom_mouse_cursor(null)
			finished_level_menu.visible = true


func _on_body_entered(body):
	if body == player:
		has_player_entered = true
		plane_sprite.texture = plane_activate


func _on_body_exited(body):
	if body == player:
		has_player_entered = false
		plane_sprite.texture = plane_normal
