extends Control

@onready var timer = $"../UI/Timer"
@onready var best_time_label = $BestTime
var fastest_time = 0
var file

func _process(delta):
	if visible:
		if get_tree().current_scene.name == "World2":
			var current_time = timer.time_remaining
			file = FileAccess.open("saves/save_time_world2.json", FileAccess.READ)
			if file:
				var save_text = file.get_as_text()
				file.close()
				var json = JSON.new()
				var result = json.parse(save_text)
				var load_data = json.get_data()
				if load_data and load_data > current_time:
					fastest_time = load_data
				else:
					fastest_time = current_time
						
			var minutes = int(fastest_time / 60)
			var seconds = int(int(fastest_time) % 60)
			var milliseconds = int((fastest_time - floor(current_time)) * 1000)
			if fastest_time == current_time:
				best_time_label.text = "New Record!: " + str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2) + "." + str(milliseconds).pad_zeros(3)
			else:
				best_time_label.text = "Best Time: " + str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2) + "." + str(milliseconds).pad_zeros(3)
			var save_data = fastest_time
			file = FileAccess.open("saves/save_time_world2.json", FileAccess.WRITE)
			if file:
				file.store_string(JSON.stringify(save_data))
				file.close()
			else:
				print("Progress NOT saved.")
			
			
		elif get_tree().current_scene.name == "World3":
				var current_time = timer.time_remaining
				file = FileAccess.open("saves/save_time_world3.json", FileAccess.READ)
				if file:
					var save_text = file.get_as_text()
					file.close()
					var json = JSON.new()
					var result = json.parse(save_text)
					var load_data = json.get_data()
					if load_data and load_data > current_time:
						fastest_time = load_data
					else:
						fastest_time = current_time
							
				var minutes = int(fastest_time / 60)
				var seconds = int(int(fastest_time) % 60)
				var milliseconds = int((fastest_time - floor(current_time)) * 1000)
				if fastest_time == current_time:
					best_time_label.text = "New Record!: " + str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2) + "." + str(milliseconds).pad_zeros(3)
				else:
					best_time_label.text = "Best Time: " + str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2) + "." + str(milliseconds).pad_zeros(3)
				
				var save_data = fastest_time
				file = FileAccess.open("saves/save_time_world3.json", FileAccess.WRITE)
				if file:
					file.store_string(JSON.stringify(save_data))
					file.close()
				else:
					print("Progress NOT saved.")

func _on_next_level_pressed():
	get_tree().paused = false
	visible = false
	if get_tree().current_scene.name == "World":
		var save_data = "res://Scenes/World2.tscn"
		var file = FileAccess.open("saves/save_world.json", FileAccess.WRITE)
		if file:
			file.store_string(JSON.stringify(save_data))
			file.close()
		else:
			print("Progress NOT saved.")
		get_tree().change_scene_to_file("res://Scenes/PrologueWorld2.tscn")
		
	elif get_tree().current_scene.name == "World2":
		var save_data = "res://Scenes/World3.tscn"
		file = FileAccess.open("saves/save_world.json", FileAccess.WRITE)
		if file:
			file.store_string(JSON.stringify(save_data))
			file.close()
		else:
			print("Progress NOT saved.")
		get_tree().change_scene_to_file("res://Scenes/PrologueWorld3.tscn")
		
	elif get_tree().current_scene.name == "World3":
		var save_data = "res://Scenes/World3.tscn"
		file = FileAccess.open("saves/save_world.json", FileAccess.WRITE)
		if file:
			file.store_string(JSON.stringify(save_data))
			file.close()
		else:
			print("Progress NOT saved.")
		get_tree().change_scene_to_file("res://Scenes/Epilogue.tscn")


func _on_retry_level_pressed():
	get_tree().paused = false
	visible = false
	get_tree().reload_current_scene()


func _on_quit_to_main_menu_pressed():
	get_tree().paused = false
	visible = false
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
	
func _ready():
	if get_tree().current_scene.name != "World":
		best_time_label.visible = true
	else:
		best_time_label.visible = false
