extends Control

var counter = 0
@onready var page2 = $Page2
@onready var button = $Button

func _on_button_button_up():
	if counter == 0:
		page2.visible = true
		button.text = "You are going to do one final loop\nof the training course before taking off."
		
	if counter == 1:
		get_tree().change_scene_to_file("res://World.tscn")
		
	counter += 1 
