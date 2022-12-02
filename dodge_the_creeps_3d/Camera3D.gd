extends Camera3D

@export var lerp_speed = 3.0
@export var target_path: NodePath
@export var offset = Vector3(-8, 12, 8)

var target = null
var wobble_count = 0
const wobble_scale = 40

func _ready():
	if target_path:
		target = get_node(target_path)

func _physics_process(delta):
	if target_path:
		target = get_node(target_path)
	if !target:
		return
	var o = offset
	if 0 < wobble_count:
		wobble_count -= 1
		var scale = wobble_scale + wobble_count
		o += Vector3(scale * (randf() - 0.5), scale * (randf() - 0.5), scale * (randf() - 0.5))
	var target_xform = target.global_transform.translated_local(o)
	global_transform = global_transform.interpolate_with(target_xform, lerp_speed * delta) 
	look_at(target.global_transform.origin, target.transform.basis.y)


func _on_player_squash():
	wobble_count = 40
