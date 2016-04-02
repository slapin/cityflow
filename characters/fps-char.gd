
extends RigidBody

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	set_mode(MODE_CHARACTER)
	set_fixed_process(true)
func _fixed_process(dt):
	var impulse = Vector3()
	if Input.is_action_pressed("char_forward"):
		impulse = impulse - get_transform().basis[2] * 30
	if Input.is_action_pressed("char_left"):
#		impulse = impulse - get_transform().basis[0] * 3
		set_transform(get_transform().rotated(Vector3(0.0, 1.0, 0.0), -0.03))
	elif Input.is_action_pressed("char_right"):
#		impulse = impulse + get_transform().basis[0] * 3
		set_transform(get_transform().rotated(Vector3(0.0, 1.0, 0.0), 0.03))
	var v = get_linear_velocity()
	v.y = 0
	if v.length() * 3.6 < 20:
		apply_impulse(Vector3(0.0, 0.0, 0.0), impulse)
	

