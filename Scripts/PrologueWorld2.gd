extends Control

var counter = 0
@onready var page2 = $Page2
@onready var page3 = $Page3
@onready var button = $Button

func _on_button_button_up():
	if counter == 0:
		page2.visible = true
		button.text = "However, you quickly start getting overrun\nby the enemy and you have to fall back."
		
	if counter == 1:
		page3.visible = true
		button.text = "Amidst the chaos you realize you've lost\nyour way from the squad. You must reach the radio tower\nto request pickup before it is too late!"

	if counter == 2:
		get_tree().change_scene_to_file("res://Scenes/World2.tscn")
		
	counter += 1 
