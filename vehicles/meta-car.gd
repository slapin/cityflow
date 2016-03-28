
extends VehicleBody

# member variables here, example:
# var a=2
# var b="textvar"
onready var col_slow = get_node("col-slow")
onready var col_slow_left = get_node("col-slow_left")
onready var col_slow_right = get_node("col-slow_right")
onready var col_stop = get_node("col-stop")
onready var col_left = get_node("col-left")
onready var col_right = get_node("col-right")
onready var col_ground = get_node("col-ground")
onready var vel = get_translation()
var oldvel = Vector3()

const SPEEDING = 0
const SLOWING = 1
const CORRECTING = 2
const STOPPED = 3
const CORRECT_LEFT = 4
const CORRECT_RIGHT = 5
const IDLE = 6
var state = IDLE
var steer_correct = 0.9
var steer_nav = 0.9

var speed_max = 80.0
var speed_min = 30.0
var correction_speed_max = 30
var correction_speed_min = 6.0

var orig_force = 0.0
onready var olddir = get_transform().basis[2]
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_friction(1.0)
	olddir.y = 0
	state = IDLE
	set_fixed_process(true)

func slow_collide():
	for h in [col_slow, col_slow_left, col_slow_right]:
		if h.is_colliding():
			var ob = h.get_collider()
			if ob extends StaticBody:
				if col_stop.get_collision_point().y < 0.2:
					continue
				else:
					return true
			else:
				return true
			return true
	return false

func stop_collide():
	if col_stop.is_colliding():
		var ob = col_stop.get_collider()
		if ob extends StaticBody:
			if col_stop.get_collision_point().y < 0.2:
				return false
			else:
				return true
		else:
			return true
	return false

func ground_collide():
	if col_ground.is_colliding():
		var ob = col_ground.get_collider()
		if ob extends StaticBody:
			if col_stop.get_collision_point().y < 0.2:
				return true
			else:
				return false
		else:
			return false
	return false

func check_contacts():
	if col_left.is_colliding() or col_right.is_colliding():
		return true
	elif slow_collide() or stop_collide():
		return true
	else:
		return false

func switch_state(s):
	if state != s:
#		print(get_name(), ": state: ", s)
		state = s
		if s == STOPPED:
			set_engine_force(-80)
			set_steering(0)
			set_brake(1.0)
#			print("stop")
		elif s == SLOWING:
			set_steering(0.0)
			set_engine_force(40.0)
			set_brake(1.0)
		elif s == SPEEDING:
			set_steering(0.0)
			set_brake(0.0)
		elif s == CORRECTING:
#			print("correcting")
			set_steering(0)
			set_brake(0.0)
		elif s in [CORRECT_LEFT, CORRECT_RIGHT]:
			set_engine_force(0)
			set_steering(0.0)
			set_brake(0.5)
		elif s == IDLE:
			set_steering(0.0)
			set_brake(1.0)
			set_engine_force(0.0)

onready var direction = get_transform().basis[2]
var dval = 0.0
var oldsign = -1
var speed = 0.0
var st = 0.0
func _fixed_process(dt):
	var oldv = vel
	vel = get_translation()
	oldvel = (vel - oldv + oldvel) / 2.0
	var dv = oldvel / dt
	speed = dv.length() * 3.6
	direction.y = 0
	var ef = get_engine_force()
	st = get_steering()
	if state in [SPEEDING, SLOWING]:
		if check_contacts():
			switch_state(CORRECTING)
		if abs(dval) > 0.001:
			st = steer_nav * dval
#			print(get_name() + ": dval:", dval)
			set_steering(st)
		else:
			st = 0.0
			set_steering(st)
			
	if state == SPEEDING:
		if speed > speed_max:
			ef = ef * 0.5
		else:
			ef = ef + 0.2
			ef = ef * 1.1
		if abs(dval) > 0.001 and ef > 40.0:
			ef = ef * 0.8
		set_engine_force(ef)
		if not ground_collide():
			switch_state(SLOWING)
	elif state == SLOWING:
		if speed < speed_min and not slow_collide():
			switch_state(SPEEDING)
		else:
			ef = 0.0
			set_engine_force(ef)
	elif state == CORRECTING:
		if speed > correction_speed_max:
			ef = 0.0
		elif speed < correction_speed_min:
			ef = ef + 0.1
			ef = ef * 1.1

		if check_contacts():
			if col_left.is_colliding() and col_right.is_colliding():
				st = 0.0
				ef = 0.0
			elif col_left.is_colliding():
				switch_state(CORRECT_LEFT)
			elif col_right.is_colliding():
				switch_state(CORRECT_RIGHT)
			elif stop_collide():
				switch_state(STOPPED)
#				print("stop")
			elif slow_collide():
#				print("slow")
				switch_state(STOPPED)
#		print("steering: ", st, " engine force: ", ef, " speed: ", speed)
		set_engine_force(ef)
		set_steering(st)
		if not check_contacts():
			switch_state(SLOWING)
	elif state == STOPPED:
		if stop_collide():
			if ef > 0.0:
				ef = -40
			else:
				ef = ef - 0.5
			if col_left.is_colliding() and col_right.is_colliding():
				st = 0.0
			elif col_left.is_colliding():
				st = -steer_correct
			elif col_right.is_colliding():
				st = steer_correct
			else:
				st = 0.0
			set_steering(st)
			set_engine_force(ef)
		elif col_ground.is_colliding():
			st = 0.0
			set_steering(st)
			switch_state(SPEEDING)
				
	elif state == CORRECT_LEFT:
		print(get_name(), ": correcting left")
		if speed > correction_speed_max:
			ef = 0.0
		elif speed < correction_speed_min:
			ef = ef + 0.1
			ef = ef * 1.1
		st = steer_correct
		set_steering(st)
		set_engine_force(ef)
		if not col_left.is_colliding():
			switch_state(SLOWING)
	elif state == CORRECT_RIGHT:
		print(get_name(), ": correcting right")
		if speed > correction_speed_max:
			ef = 0.0
		elif speed < correction_speed_min:
			ef = ef + 0.1
			ef = ef * 1.1
		st = -steer_correct
		set_steering(st)
		set_engine_force(ef)
		if not col_right.is_colliding():
			switch_state(SLOWING)
	elif state == IDLE:
		pass
	
	
