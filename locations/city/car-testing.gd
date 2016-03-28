
extends Spatial

# member variables here, example:
# var a=2
# var b="textvar"
onready var car = get_node("car")
onready var car1 = get_node("car1")
onready var path = get_node("Path")
onready var label = get_node("label")

onready var curve = Array(path.get_curve().get_baked_points())

var goal
onready var fuc = TestCube.new()
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	var start = 0
	var dist = car.get_translation().distance_squared_to(curve[start])
	var dir = car.get_transform().basis[2]
	for l in range(1, curve.size()):
		var pos = curve[l]
		var loc = car.get_translation()
		if pos.distance_squared_to(loc) < dist:
			if dir.dot(pos - loc) >= 0:
				start = l
	goal = start
	car.set_engine_force(50)
	car.switch_state(car.SPEEDING)
	car1.set_engine_force(50)
	car1.switch_state(car.SPEEDING)
	car.dval = 0.0
	car1.dval = 0.0
	label.clear()
	label.add_text("starting\n")
	var cb = TestCube.new()
	add_child(cb)
	cb.set_translation(curve[goal])
	car.add_child(fuc)
	fuc.set_translation(car.get_transform().xform_inv(curve[goal]))
	set_fixed_process(true)

var clear_label = 2.0
var count_time = 0.0
var sgn = 0.0
func _fixed_process(dt):
	var steerv = car.get_transform().xform_inv(curve[goal])
	var steer
	steer = -steerv.normalized().x
	var loc = car.get_translation()
	var pos = curve[goal]
	var target = curve[goal]
	var pdir = car.get_transform().basis[2]
	pdir.y = 0
	var vdir = target - loc
	vdir.y = 0
	var dval = steer
	if count_time >= clear_label or sgn != sign(dval):
		sgn = sign(dval)
		label.clear()
		count_time = 0
	else:
		count_time += dt
	label.add_text("loc: " + str(loc))
	label.add_text(" target: " + str(target))
	label.add_text(" dval: " + str(dval))
	label.add_text(" car state: "+ str(car.state))
#	label.add_text(" speed: " +str(car.speed))
	label.add_text(" steering: [" + str(car.st) + " " + str(car.get_steering()) + " " + str(steer) + " (" + str(steerv) + ")]")
	label.add_text("\n")
	car.dval = dval
	if loc.distance_squared_to(target) < 9.0:
		label.clear()
		while loc.distance_squared_to(target) < 64.0 or steerv.normalized().z < 0.0:
			goal = int(fmod((goal + 1), curve.size()))
			target = curve[goal]
		
#		var cb = TestCube.new()
#		add_child(cb)
#		cb.set_translation(curve[goal])
	fuc.set_translation(car.get_transform().xform_inv(curve[goal]))
	