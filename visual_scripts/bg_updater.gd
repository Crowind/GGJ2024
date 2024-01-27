extends Node2D
class_name BgUpdater

var brushes:Array[Node]

@export var poolsize:int
@export var viewport:SubViewport
@export var tilemap:TileMap
var currentIndex:int


# Called when the node enters the scene tree for the first time.
func _ready():
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_NEVER
	currentIndex=0;
	brushes.resize(poolsize)
	for i in range(0,poolsize):
		
		var scene = load("res://scenes/laughter_effect.tscn")
		brushes[i] = scene.instantiate()
		brushes[i]._deactivate()
		viewport.add_child(brushes[i])
	
	for child in tilemap.get_children():
		var enemy_child: EnemyBase = child as EnemyBase
		if enemy_child != null:
			enemy_child.on_laughing.connect(_dispatch_laughter)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	pass

func _dispatch_laughter(normalized_position:Vector2):
	
	var absolute_position = Vector2(lerp(0,viewport.size.x,normalized_position.x),lerp(0,viewport.size.y,normalized_position.y))
	brushes[currentIndex]._activate(absolute_position);
	currentIndex = (currentIndex+1) % poolsize;
	
func _fill_percentage() -> float:

		var count:float = 0
		var image:Image = viewport.get_texture().get_image()
		var size = image.get_size()
#
		for x in range(0,size.x):
			for y in range(0,size.y):
				count += image.get_pixel(x,y).a

		return count/(size.x*size.y)
	
func _deploy_joke(joke:Node):
	
	tilemap.add_child(joke)



func _on_timer_timeout():
	_dispatch_laughter(Vector2(randf_range(0,1),randf_range(0,1)))
