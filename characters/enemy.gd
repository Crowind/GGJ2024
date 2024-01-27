extends CharacterBody2D
class_name EnemyBase

@export var speed = 100.0

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var timer: Timer = $Timer

# temp, understand how to do this correctly
@export var min_rand: Vector2 = Vector2(0, 0)
@export var max_rand: Vector2 = Vector2(500, 500)

@export var min_idle_time: float = 0.1
@export var max_idle_time: float = 1


enum State
{
	Idle,
	Walking,
	Smiling,
	Suffering
}
var current_state: State = State.Idle


func _ready():
	timer.start(randf_range(min_idle_time, max_idle_time))


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


func _choose_next_state():
	if current_state == State.Idle:
		current_state = State.Walking


func _randomize_vector2() -> Vector2:
	var x: float = randf_range(min_rand.x, max_rand.x)
	var y: float = randf_range(min_rand.y, max_rand.y)
	return Vector2(x, y)


func _create_path():
	var random_target: Vector2 = _randomize_vector2()
	navigation_agent.target_position = random_target
	current_state = State.Walking
	timer.stop()


func _on_timer_timeout():
	_create_path()


func _on_navigation_agent_2d_navigation_finished():
	pass # Replace with function body.


func _on_navigation_agent_2d_target_reached():
	print("Target Reached")
	timer.start(randf_range(min_idle_time, max_idle_time))
	current_state = State.Idle


func _on_navigation_agent_2d_path_changed():
	pass


func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	velocity = safe_velocity
	move_and_slide()
