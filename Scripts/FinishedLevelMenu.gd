extends Control

@onready var timer = $"../UI/Timer"
@onready var best_time_label = $BestTime
var fastest_time = 0

var level_data = {
	"World2": {
		"save_file": "saves/save_time_world2.json",
		"next_scene": "res://Scenes/PrologueWorld3.tscn",
		"next_level": "res://Scenes/World3.tscn"
	},
	"World3": {
		"save_file": "saves/save_time_world3.json",
		"next_scene": "res://Scenes/Epilogue.tscn",
		"next_level": null
	}
}


func _process(delta):
	if visible:
		var current_scene_name = get_tree().current_scene.name
		if level_data.has(current_scene_name):
			best_time_label.visible = true
			update_fastest_time(current_scene_name)
		else:
			best_time_label.visible = false


func update_fastest_time(scene_name):
	var current_time = timer.time_remaining
	var path = level_data[scene_name]["save_file"]
	var saved_time = load_time(path)
	
	if saved_time == null or current_time > saved_time:
		fastest_time = current_time
		save_time(path, current_time)
	else:
		fastest_time = saved_time
	
	var minutes = int(fastest_time / 60)
	var seconds = int(fastest_time) % 60
	var milliseconds = int((fastest_time - floor(fastest_time)) * 1000)
	var label_prefix
	if fastest_time == current_time:
		label_prefix = "New Record!: " 
	else:
		label_prefix = "Best Time: "
	best_time_label.text = label_prefix + str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2) + "." + str(milliseconds).pad_zeros(3)


func load_time(path):
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var text = file.get_as_text()
		file.close()
		var json = JSON.new()
		if json.parse(text) == OK:
			return json.get_data()
	return null


func save_time(path, time_value):
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(time_value))
		file.close()


func _on_next_level_pressed():
	get_tree().paused = false
	visible = false
	
	var current_scene = get_tree().current_scene.name
	var save_path = "saves/save_world.json"
	
	if current_scene == "World":
		save_path(save_path, "res://Scenes/World2.tscn")
		get_tree().change_scene_to_file("res://Scenes/PrologueWorld2.tscn")
	elif level_data.has(current_scene):
		save_path(save_path, level_data[current_scene]["next_level"])
		get_tree().change_scene_to_file(level_data[current_scene]["next_scene"])


func save_path(path, scene_path):
	var save_data = {
		"current_level": scene_path
	}
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
	else:
		print("Progress NOT saved.")


func _on_retry_level_pressed():
	get_tree().paused = false
	visible = false
	get_tree().reload_current_scene()


func _on_quit_to_main_menu_pressed():
	get_tree().paused = false
	visible = false
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
