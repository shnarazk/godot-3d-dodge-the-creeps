extends Node

@export var mob_scene: PackedScene


func _ready():
	randomize()
	$UserInterface/Retry.hide()


func _unhandled_input(event):
	if not $UserInterface/Retry.visible:
		return
	if event.is_action_pressed("replay"):
		# warning-ignore:return_value_discarded
		get_tree().reload_current_scene()
	elif event.is_action_pressed("ui_end") or event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _on_MobTimer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location checked the SpawnPath.
	var mob_spawn_location = get_node("SpawnPath/SpawnLocation")
	mob_spawn_location.progress_ratio = randf()

	# Communicate the spawn location and the player's location to the mob.
	if $Player == null:
		return
	var player_position = $Player.transform.origin
	mob.initialize(mob_spawn_location.position, player_position)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)
	# We connect the mob to the score label to update the score upon squashing a mob.
	mob.connect("squashed",Callable($UserInterface/ScoreLabel,"_on_Mob_squashed"))


func _on_Player_hit():
	$MobTimer.stop()
	$UserInterface/Retry.show()
