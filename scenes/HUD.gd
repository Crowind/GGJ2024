extends CanvasLayer
@export var icon_banana: Texture2D
@export var icon_jack: Texture2D
@export var icon_poo: Texture2D
@export var icon_manhole: Texture2D

@export var bg_updater:BgUpdater

@export var joke_poo:PackedScene
@export var joke_jack:PackedScene
@export var joke_manhole:PackedScene
@export var joke_banana:PackedScene

var index:JokeType

enum JokeType
{
	Jack = 0,
	Poo = 1,
	Manhole = 2,
	Banana = 3 
}
func _ready():
	index = JokeType.Banana
	_icon_change()
	
func _process(delta):
	
	pass
		
	
func _icon_change():
	if index == JokeType.Jack:
		get_node("BG/Icon").texture = icon_jack
	elif index == JokeType.Poo:
		get_node("BG/Icon").texture = icon_poo
	elif index == JokeType.Manhole:
		get_node("BG/Icon").texture = icon_manhole
	elif index == JokeType.Banana:
		get_node("BG/Icon").texture = icon_banana
		
		

func _input(event):
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("joke_cycle"):
			index = (index+1) % JokeType.size()
			_icon_change()
			
		
		if Input.is_action_just_pressed("joke_deploy"):
			var joke:Node;
			match index:
				JokeType.Jack:
					joke = joke_jack.instantiate()
				JokeType.Poo:
					joke = joke_poo.instantiate()
				JokeType.Manhole:
					joke = joke_manhole.instantiate()
				JokeType.Banana:
					joke = joke_banana.instantiate()

			joke.position = event.global_position
						
			bg_updater._deploy_joke(joke)
