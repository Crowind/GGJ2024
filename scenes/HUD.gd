extends CanvasLayer
@export var icon_banana: Texture2D
@export var icon_jack: Texture2D
@export var icon_poo: Texture2D
@export var icon_manhole: Texture2D

@export var bg_updater: BgUpdater

@export var joke_poo: PackedScene
@export var joke_jack: PackedScene
@export var joke_manhole: PackedScene
@export var joke_banana: PackedScene

@export var tile_map: TileMap
@export var camera: Camera2D

@export var cooldown_duration: float
var last_deploy: float

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
	var coordinates: Vector2i = tile_map.local_to_map(tile_map.get_local_mouse_position())
	var tile_data: TileData = tile_map.get_cell_tile_data(0, coordinates)
	
	var on_char: bool = _check_if_on_character(get_viewport().get_mouse_position())
	var terrain_ok: bool = true
	
	if tile_data != null:
		var terrain_Type = tile_data.get_custom_data("TerrainType")
		terrain_ok = _check_terrain(terrain_Type)
	
	_change_curson_color(on_char || terrain_ok)
	
	var t: float = (Time.get_ticks_msec() - last_deploy) / cooldown_duration 
	((get_node("BG") as TextureRect).material as ShaderMaterial).set_shader_parameter("fill",t)


func _icon_change():
	if index == JokeType.Jack:
		get_node("BG/Icon").texture = icon_jack
	elif index == JokeType.Poo:
		get_node("BG/Icon").texture = icon_poo
	elif index == JokeType.Manhole:
		get_node("BG/Icon").texture = icon_manhole
	elif index == JokeType.Banana:
		get_node("BG/Icon").texture = icon_banana


func _check_if_on_character(point: Vector2) -> bool:
	# get the Physics2DDirectSpaceState object
	var space = camera.get_world_2d().direct_space_state
	# Check if there is a collision at the mouse position
	var point_query: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
	point_query.collide_with_areas = true
	point_query.collide_with_bodies = false
	point_query.collision_mask = 128
	point_query.position = point
	var colliding_objects: Array[Dictionary] = space.intersect_point(point_query, 1)
	#for element in colliding_objects:
	#	print("hit something: " + str(element))
	return colliding_objects.size() > 0
	#else:
	#	print("no hit")
	#	return false


func _input(event):
	if !(event is InputEventMouseMotion):
		print(event)
	
	if event is InputEventMouseButton:
	
		var coordinates: Vector2i = tile_map.local_to_map( tile_map.get_local_mouse_position() )
		var tile_data: TileData = tile_map.get_cell_tile_data(0,coordinates)
		
		var on_char: bool = _check_if_on_character(get_viewport().get_mouse_position())
		var terrain_ok: bool = true
		if tile_data != null:
			var terrain_Type = tile_data.get_custom_data("TerrainType")
			terrain_ok = _check_terrain(terrain_Type)
			
		var can_click: bool = !(on_char || terrain_ok)
	
		can_click = can_click && (last_deploy + cooldown_duration < Time.get_ticks_msec())

		if Input.is_action_just_pressed("joke_cycle"):
			index = (index+1) % JokeType.size()
			_icon_change()	
		
		if (Input.is_action_just_pressed("joke_deploy") && can_click):
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
			var mouse_pos = get_viewport().get_mouse_position()
			joke.position = mouse_pos
			bg_updater._deploy_joke(joke)
			last_deploy= Time.get_ticks_msec()


func _check_terrain(terrain_type: String) -> bool:
	var is_blocked: bool = false;
	
	if terrain_type == "wall":
		is_blocked = true;
		
	if terrain_type == "sidewalk":
		if index == JokeType.Manhole:
			is_blocked=true
	if terrain_type == "road":
		if index == JokeType.Jack || index == JokeType.Poo:
			is_blocked = true

	return is_blocked


func _change_curson_color(is_blocked: bool):
	var unblocked = load("res://gfx/assets/UI/cursor.png")
	var blocked = load("res://gfx/assets/UI/cursor_blocked.png")
	
	if(is_blocked):
		Input.set_custom_mouse_cursor(blocked, Input.CURSOR_ARROW, Vector2(25, 25))
	else:
		Input.set_custom_mouse_cursor(unblocked, Input.CURSOR_ARROW, Vector2(25, 25))

