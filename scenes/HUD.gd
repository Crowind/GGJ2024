extends CanvasLayer
@export var icon_banana: Texture2D
@export var icon_jack: Texture2D
@export var icon_poo: Texture2D
@export var icon_manhole: Texture2D
var index = 0

enum JokeType
{
	Jack = 1,
	Poo = 2,
	Manhole = 3,
	Banana = 4
}

func _process(delta):
	
	if Input.is_action_just_pressed("joke_cycle"):
		index += 1
		_icon_change()
		
func _icon_change():
	if index == JokeType.Jack:
		get_node("BG/Icon").texture = icon_jack
	elif index == JokeType.Poo:
		get_node("BG/Icon").texture = icon_poo
	elif index == JokeType.Manhole:
		get_node("BG/Icon").texture = icon_manhole
	elif index == JokeType.Banana:
		get_node("BG/Icon").texture = icon_banana
		index = 0
