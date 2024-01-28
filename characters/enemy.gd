extends CharacterBody2D
class_name EnemyBase

signal on_laughing(laugh_position: Vector2)

var speed = 100.0

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var change_state_timer: Timer = $ChangeStateTimer
@onready var no_happiness_timer: Timer = $NoHappinessAddTimer
@onready var chase_character_timer: Timer = $ChaseCharacterTimer
@onready var fight_timer: Timer = $FightTimer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var stats: CharacterStats = $CharacterStats
@onready var laugh_contagion_collision: CollisionShape2D = $LaughContagionArea2D/LaughContagionCollisionShape2D
@onready var laugh_particles: GPUParticles2D = $LaughParticles
@onready var character_detection_area: Area2D = $CharacterDetectionArea2D

var tile_map: TileMap
var min_rand: Vector2
var max_rand: Vector2

@export var aggressive_with: Array[BaseJoke.Types]
@export var min_idle_time: float = 0.1
@export var max_idle_time: float = 1
@export var min_no_happiness_time: float = 3
@export var max_no_happiness_time: float = 5
@export var chasing_speed: float = 5000
@export var fight_duration: float = 1

var current_joke: BaseJoke
var laugh_contagion_disabled: bool = true
var can_add_happiness_on_other_laughing_seen: bool = true

var become_aggressive_when_end_suffering: bool = false
var target_character: EnemyBase


enum State
{
	Idle,
	Walking,
	Smiling,
	Suffering,
	ChasingTarget,
	Fighting,
	BeenBeated
}
var current_state: State = State.Idle


func _ready():
	tile_map = get_parent() as TileMap
	var tile_size: Vector2i = tile_map.tile_set.tile_size
	var user_rect: Rect2i = tile_map.get_used_rect()
	user_rect.size *= tile_size
	min_rand = user_rect.position as Vector2 * tile_map.scale
	max_rand = user_rect.size as Vector2 * tile_map.scale
	change_state_timer.start(randf_range(min_idle_time, max_idle_time))
	animated_sprite.play("idle_down")
	speed = stats.speed_enum_to_speed()
	laugh_contagion_collision.disabled = laugh_contagion_disabled
	laugh_particles.visible = true
	laugh_particles.emitting = false

	animated_sprite.material = animated_sprite.material.duplicate(true)




func _process(delta: float):
	# basic happiness consumption
	if current_state != State.Smiling:
		stats.happiness += stats.happiness_consumption_per_sec * delta
	
	_update_animations()
	if laugh_contagion_disabled != laugh_contagion_collision.disabled:
		laugh_contagion_collision.disabled = laugh_contagion_disabled
	
	if current_state == State.ChasingTarget:
		if (target_character.global_position - global_position).length_squared() < 32 * 32:
			_stop_immediately()
			current_state = State.Fighting
			chase_character_timer.stop()
			target_character.attacked()
			fight_timer.start(fight_duration)

	var linear_happiness = inverse_lerp(stats.min_happiness,stats.happiness_treshold,stats.happiness)
	linear_happiness = clampf(linear_happiness,-0.2,1.5)
	(animated_sprite.material as ShaderMaterial).set_shader_parameter("saturation", linear_happiness)


func _physics_process(delta):
	match current_state:
		State.Walking:
			if navigation_agent.is_target_reachable() && !navigation_agent.is_navigation_finished():
				var movement_delta: float = speed * delta
				var agent_position: Vector2 = global_position
				var next_path_position: Vector2 = navigation_agent.get_next_path_position()
				navigation_agent.velocity = (next_path_position - agent_position).normalized() * movement_delta
			else:
				_on_navigation_agent_2d_target_reached()
		State.ChasingTarget:
			if target_character != null:
				var movement_delta: float = speed * delta
				var agent_position: Vector2 = global_position
				var next_path_position: Vector2 = navigation_agent.get_next_path_position()
				navigation_agent.velocity = (next_path_position - agent_position).normalized() * movement_delta


func _update_walking_anims():
	if !velocity.is_zero_approx():
		var angle_deg = rad_to_deg(velocity.angle())
		#print(str(angle_deg))
		if (angle_deg < 0 && angle_deg >= -60) || (angle_deg >= 0 && angle_deg <= 60):
			animated_sprite.play("walk_side")
			animated_sprite.flip_h = false
		elif (angle_deg <= 180 && angle_deg >= 120) || (angle_deg >= -180 && angle_deg <= -120):
			animated_sprite.play("walk_side")
			animated_sprite.flip_h = true
		elif angle_deg > 60 && angle_deg < 120:
			animated_sprite.play("walk_down")
		else:
			animated_sprite.play("walk_up")
	else:
		animated_sprite.play("idle_down")


func _update_animations():
	match current_state:
		State.Walking:
			_update_walking_anims()
		State.ChasingTarget:
			_update_walking_anims()
		State.Idle:
			animated_sprite.play("idle_down")


func _randomize_vector2() -> Vector2:
	var x: float = randf_range(min_rand.x, max_rand.x)
	var y: float = randf_range(min_rand.y, max_rand.y)
	return Vector2(x, y)


func _create_path():
	var random_target: Vector2 = _randomize_vector2()
	navigation_agent.target_position = random_target
	current_state = State.Walking
	change_state_timer.stop()


func _create_path_for_target():
	if target_character != null:
		navigation_agent.target_position = target_character.global_position
		current_state = State.ChasingTarget
		print("chase position: " + str(navigation_agent.target_position))
		change_state_timer.stop()


func _find_nearest_character_and_beat_it():
	pass


func _on_timer_timeout():
	laugh_contagion_disabled = true
	current_joke = null
	laugh_particles.emitting = false
	if !become_aggressive_when_end_suffering:
		_create_path()
	else:
		var overlapping_nodes: Array[Node2D] = character_detection_area.get_overlapping_bodies()
		var min_dist: float = 999999999999
		var choosed_character: EnemyBase = null
		for overlapping_node: Node2D in overlapping_nodes:
			var overlapping_character: EnemyBase = overlapping_node as EnemyBase
			if overlapping_character != null && overlapping_character != self:
				var distance: float = (global_position - overlapping_character.global_position).length_squared()
				if distance < min_dist:
					min_dist = distance
					choosed_character = overlapping_character
		if choosed_character != null:
			print("character choosed!!!")
			animated_sprite.self_modulate = Color.RED
			target_character = choosed_character
			become_aggressive_when_end_suffering = false
			current_state = State.ChasingTarget
			chase_character_timer.start()
			speed = chasing_speed


func _on_navigation_agent_2d_navigation_finished():
	pass


func _on_navigation_agent_2d_target_reached():
	#print("Target Reached")
	change_state_timer.start(randf_range(min_idle_time, max_idle_time))
	current_state = State.Idle
	_stop_immediately()


func _on_navigation_agent_2d_path_changed():
	pass


func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	if current_state == State.Walking || current_state == State.ChasingTarget:
		velocity = safe_velocity
		move_and_slide()


func _stop_immediately():
	velocity = Vector2.ZERO
	navigation_agent.velocity = Vector2.ZERO


func get_normalized_poisition_on_map() -> Vector2:
	return position / max_rand


func on_joke_entered(joke: BaseJoke):
	print("on joke entered: " + name)
	current_state = State.Suffering
	animated_sprite.play(joke.animation_to_play)
	_stop_immediately()
	stats.happiness += joke.happiness_to_remove
	change_state_timer.start(joke.joke_duration)
	if aggressive_with.find(joke.type) != -1:
		become_aggressive_when_end_suffering = true


func on_joke_exited(_joke: BaseJoke):
	print("on joke exited: " + name)


func apply_laugh(laugh_value: float, smile_duration: float) -> bool:
	if current_state == State.Suffering:
		print("non c'è niente da ridere!!!: " + name)
		return false
	print("ridi stronzo!!!: " + name)
	if current_state != State.Smiling:
		if stats.add_happiness(laugh_value):
			_stop_immediately()
			current_state = State.Smiling
			animated_sprite.play("smile")
			change_state_timer.start(smile_duration)
			laugh_contagion_disabled = false
			laugh_particles.emitting = true
			emit_signal("on_laughing", get_normalized_poisition_on_map())
			return true
		else:
			print("scherzo visto ma non rido ancora: " + name + ", " + str(stats.happiness))
			can_add_happiness_on_other_laughing_seen = false
			no_happiness_timer.start(randf_range(min_no_happiness_time, max_no_happiness_time))
	return false


func on_laugh_area_entered(joke: BaseJoke):
	if apply_laugh(joke.happiness_to_add, joke.smile_duration):
		current_joke = joke


func on_other_char_laugh_seen(joke: BaseJoke):
	if !can_add_happiness_on_other_laughing_seen:
		print("ho visto un char ridere ma non rido: " + name)
		return false
	apply_laugh(stats.happines_to_add_on_joke_seen, joke.smile_duration)


func on_laugh_area_exited(_joke: BaseJoke):
	print("smetti di ridere stronzo!!!: " + name)


func _on_laugh_contagion_area_2d_body_entered(body):
	if current_joke != null:
		var enemy: EnemyBase = body as EnemyBase
		enemy.on_other_char_laugh_seen(current_joke)
		print("sorriso contagiato!!!: " + name)


func _on_laugh_contagion_area_2d_body_exited(body):
	pass # Replace with function body.


func _on_no_happiness_add_timer_timeout():
	can_add_happiness_on_other_laughing_seen = true


func _on_chase_character_timer_timeout():
	_create_path_for_target()


func attacked():
	stats.happiness += stats.happines_damage_on_fight
	_stop_immediately()
	current_state = State.BeenBeated
	change_state_timer.stop()
	chase_character_timer.stop()


func end_attack():
	change_state_timer.start(randf_range(min_idle_time, max_idle_time))
	current_state = State.Idle


func _on_fight_timer_timeout():
	target_character.end_attack()
	target_character = null
	become_aggressive_when_end_suffering = false
	fight_timer.stop()
	change_state_timer.start(randf_range(min_idle_time, max_idle_time))
	current_state = State.Idle
	speed = stats.speed_enum_to_speed()
	animated_sprite.self_modulate = Color.WHITE


func _on_mouse_picking_area_2d_input_event(viewport: Viewport, event: InputEvent, shape_idx: int):
	if event.is_action_pressed("joke_deploy"):
		stats.happiness += stats.happines_damage_on_click
