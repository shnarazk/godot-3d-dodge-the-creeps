extends CharacterBody3D

signal hit
signal squash

# How fast the player moves in meters per second.
@export var speed = 14
# Vertical impulse applied to the character upon jumping in meters per second.
@export var jump_impulse = 20
# Vertical impulse applied to the character upon bouncing over a mob in meters per second.
@export var bounce_impulse = 16
# The downward acceleration when in the air, in meters per second per second.
@export var fall_acceleration = 75

#var velocity = Vector3.ZERO

@export var jump_trail_timer = 0
@export var jump_light_timer = 0


func _physics_process(delta):
	if position.y < -10:
		die()
	var direction = Vector3.ZERO
	#direction.x = 0.1
	if Input.is_action_pressed("move_right"):
		# direction.x += 1
		rotation.y += 0.05
	if Input.is_action_pressed("move_left"):
		# direction.x -= 1
		rotation.y -= 0.05
	direction.x = cos(rotation.y)
	direction.z = sin(rotation.y)

	#if Input.is_action_pressed("move_back"):
	#	direction.z += 1
	#if Input.is_action_pressed("move_forward"):
	#	direction.z -= 1

	if direction != Vector3.ZERO:
		# In the lines below, we turn the character when moving and make the animation play faster.
		direction = direction.normalized()
		$Pivot.look_at(position + direction, Vector3.UP)
		$AnimationPlayer.speed_scale = 4
	else:
		$AnimationPlayer.speed_scale = 1

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	# Jumping.
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y += jump_impulse
		jump_trail_timer = 5
		jump_light_timer = 100
		$CPUParticles3D.emitting = true
		$OmniLight3D.light_energy = 10
	if 0 < jump_trail_timer:
		jump_trail_timer -= 1
	else:
		$CPUParticles3D.emitting = false
	if 0 < jump_light_timer:
		jump_light_timer -= 1
		$OmniLight3D.light_energy *= 0.96
	else:
		$OmniLight3D.light_energy = 0

	# We apply gravity every frame so the character always collides with the ground when moving.
	# This is necessary for the is_on_floor() function to work as a body can always detect
	# the floor, walls, etc. when a collision happens the same frame.
	velocity.y -= fall_acceleration * delta
	set_velocity(velocity)
	set_up_direction(Vector3.UP)
	move_and_slide()
	velocity = velocity

	# Here, we check if we landed checked top of a mob and if so, we kill it and bounce.
	# With move_and_slide(), Godot makes the body move sometimes multiple times in a row to
	# smooth out the character's motion. So we have to loop over all collisions that may have
	# happened.
	# If there are no "slides" this frame, the loop below won't run.
	for index in range(get_slide_collision_count()):
		var collision = get_slide_collision(index)
		var mob = collision.get_collider()
		if mob.is_in_group("mob") and Vector3.UP.dot(collision.get_normal()) > 0.1:
			emit_signal("squash")
			mob.squash()
			velocity.y = bounce_impulse

	# This makes the character follow a nice arc when jumping
	$Pivot.rotation.x = PI / 6 * velocity.y / jump_impulse


func die():
	emit_signal("hit")
	queue_free()


func _on_MobDetector_body_entered(_body):
	die()
