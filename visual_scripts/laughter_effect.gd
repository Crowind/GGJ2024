extends Node2D

@export var sprite:Sprite2D
@export var cooldown:float;
var activation_time:float;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _activate(input_position:Vector2):
	
	_deactivate()
	position = input_position;
	sprite.visible = true;

func _deactivate():
	sprite.visible= false;
