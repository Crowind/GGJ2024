extends Node2D

@export var brushes:Array
@export var poolsize:int
@export var viewport:SubViewport
var currentIndex:int
# Called when the node enters the scene tree for the first time.
func _ready():
	currentIndex=0;
	brushes.resize(poolsize)
	for i in range(0,poolsize):
		
		var scene = load("res://Scenes/laughter_effect.tscn")
		brushes[i] = scene
		viewport.add_child(brushes[i])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _dispatch_laughter(normalized_position:Vector2):
	
	var absolute_position = Vector2(lerp(0,viewport.size.x,normalized_position.x),lerp(0,viewport.size.y,normalized_position.y))
	
	brushes[currentIndex].activate(absolute_position);
	
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
	
	
	
	
	
