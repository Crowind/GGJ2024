extends Control

@onready var game_map: PackedScene = preload("res://maps/gameplay.tscn")

func _on_quit_pressed():
	get_tree().quit()


func _on_play_pressed():
	get_tree().change_scene_to_packed(game_map)
	#get_tree().change_scene_to_file("res://maps/gameplay.tscn")
