
extends RigidBody

# member variables here, example:
# var a=2
# var b="textvar"

var state
const IDLE = 0
const WALK = 1
var speed = 1.1
var target
#onready var col_ground = get_node("col-ground")
onready var col_front = get_node("col-front")
onready var col_stop = get_node("col-stop")
onready var col_front_left = get_node("col-front-left")
onready var col_front_right = get_node("col-front-right")
onready var col_left = get_node("col-left")
onready var col_right = get_node("col-right")
onready var col_left_angle = get_node("col-left-angle")
onready var col_right_angle = get_node("col-right-angle")
var dead = false

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	state = WALK
	set_mode(MODE_CHARACTER)
	var tv = get_global_transform()
	target = tv.origin + tv.basis[2] * 10
	set_fixed_process(true)

func collisions():
	for k in [col_front, col_stop, col_front_left, col_front_right, col_left, col_right, col_left_angle, col_right_angle]:
		if k.is_colliding():
			return true
	return false

func _fixed_process(dt):
	if dead:
		return
	if state == IDLE:
		pass
	elif state == WALK:
		if not collisions():
			var tf = get_global_transform()
			var tgt = Vector3(target.x, tf.origin.y, target.z)
			tf = tf.looking_at(tgt, Vector3(0.0, 1.0, 0.0))
			set_global_transform(tf)
		var huv = get_linear_velocity()
		huv.y = 0
		if huv.length() < speed:
			var turn = 0.0
			if not col_stop.is_colliding():
				apply_impulse(Vector3(0.0, 0.0, 0.0), -get_transform().basis[2] * get_mass() * speed * dt * 100)
			if col_front_left.is_colliding():
				turn += 0.4
			elif col_front_right.is_colliding():
				turn -= 0.4
			if col_left.is_colliding():
				turn += 0.4
			elif col_right.is_colliding():
				turn -= 0.4
			if col_left_angle.is_colliding():
				turn += 0.3
			elif col_right_angle.is_colliding():
				turn -= 0.3
			if col_stop.is_colliding():
				var col = col_stop.get_collider()
				var n = col_stop.get_collision_normal()
				if turn == 0.0:
					if n.x < 0:
						turn = 1.0
					elif n.x > 0:
						turn = -1.0
			if abs(turn) == 0.0 and collisions():
				apply_impulse(Vector3(0.0, 0.0, 0.0), get_transform().basis[2] * get_mass() * speed * dt * 5)
				turn += 0.1
			var t = get_transform()
			t = t.rotated(Vector3(0.0, 1.0, 0.0), turn)
			set_transform(t)
			if abs(turn) > 0:
				apply_impulse(Vector3(0.0, 0.0, 0.0), -get_transform().basis[2] * get_mass() * speed * dt * 2)
