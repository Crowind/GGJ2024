extends Area2D
class_name BaseJoke


@onready var laugh_area: Area2D = $LaughArea
@onready var laugh_area_shape: CollisionShape2D = $LaughArea/LaughCollisionShape2D
@onready var timer: Timer = $Timer

@export var happiness_to_add: float = 2
@export var joke_lifetime: float = 10
@export var joke_duration: float = 5
@export var smile_duration: float = 5

var characters_inside: int = 0
var laugh_disabled: bool = true


# Called when the node enters the scene tree for the first time.
func _ready():
	laugh_area_shape.disabled = laugh_disabled
	timer.start(joke_lifetime)
	#set_process(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if laugh_area_shape.disabled != laugh_disabled:
		laugh_area_shape.disabled = laugh_disabled


func _on_body_entered(body):
	characters_inside += 1
	laugh_disabled = false
	var enemy: EnemyBase = body as EnemyBase
	enemy.on_joke_entered(self)


func _on_body_exited(body):
	characters_inside -= 1
	var enemy: EnemyBase = body as EnemyBase
	enemy.on_joke_exited(self)
	if characters_inside <= 0:
		characters_inside = 0
		laugh_disabled = true


func _on_laugh_area_body_entered(body):
	var enemy: EnemyBase = body as EnemyBase
	enemy.on_laugh_area_entered(self)


func _on_laugh_area_body_exited(body):
	var enemy: EnemyBase = body as EnemyBase
	enemy.on_laugh_area_exited(self)


func _on_timer_timeout():
	queue_free()
