extends SubViewport

@export var brush:Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	 # Replace with function body.
	render_target_clear_mode = SubViewport.CLEAR_MODE_NEVER

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	brush.position.x +=10*delta
