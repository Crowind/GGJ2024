extends CanvasLayer
@export var icon_banana: Texture2D
@export var icon_jack: Texture2D
@export var icon_poo: Texture2D
@export var icon_manhole: Texture2D
var index = 0

func _process(delta):
	
	if Input.is_action_just_pressed("joke_cycle"):
		index += 1
		_icon_change()
		
func _icon_change():
	if index == 1:
		get_node("BG/Icon").texture = icon_jack
	elif index == 2:
		get_node("BG/Icon").texture = icon_poo
	elif index == 3:
		get_node("BG/Icon").texture = icon_manhole
	elif index == 4:
		get_node("BG/Icon").texture = icon_banana
		index = 0
