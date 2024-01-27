extends Node
class_name CharacterStats


enum Humor
{
	Low,
	Medium,
	High
}

enum Speed
{
	Slow,
	Medium,
	Fast
}


@export var type: String
@export var humor: Humor
@export var min_happiness: float = 5
@export var max_happiness: float = 7
@export var movement_speed: Speed

var happiness: float


# Called when the node enters the scene tree for the first time.
func _ready():
	happiness = randf_range(min_happiness, max_happiness)
	set_process(false)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func speed_enum_to_speed() -> float:
	match movement_speed:
		Speed.Slow:
			return 2000.0
		Speed.Medium:
			return 3000.0
		Speed.Fast:
			return 4000.0
	return 0


func add_happiness(value: float) -> bool:
	happiness += value
	if happiness > 7:
		return true
	return false
