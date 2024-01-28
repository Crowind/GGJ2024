extends GPUParticles2D
class_name FightParticle

func start_destroy():
	emitting = false
	$Timer.start(3)

func _on_timer_timeout():
	queue_free()
