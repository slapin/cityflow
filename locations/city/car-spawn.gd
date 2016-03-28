
extends Spatial

# member variables here, example:
# var a=2
# var b="textvar"

onready var car = load("res://vehicles/meta-car.scn")
onready var place = get_translation()
onready var roll = get_rotation()
onready var spawn_col = get_node("col")
onready var target = get_node("target")

var car_limit = 500
func spawn_car():
	var car_inst = car.instance()
	get_parent().add_child(car_inst)
	car_inst.set_translation(place)
	car_inst.set_rotation(roll)
	car_inst.set_engine_force(50.0 + 100.0 * randf())
#	car_inst.set_engine_force(0.0)
	car_inst.switch_state(car_inst.SPEEDING)
	return car_inst

var car_array = []
var life_time = 60.0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	var mcar = spawn_car()
#	mcar.set_name("car" + str(car_array.size()))
#	car_array.append({"car": mcar, "time": life_time})
	set_fixed_process(true)


var spawn_period = 0.1
var pass_time = spawn_period
onready var navnode = get_parent().get_node("nav")

func set_car_direction(c):
	var direction = c.get_transform().basis[2]
	var tgt = target.get_global_transform().origin
	var start = navnode.get_closest_point(c.get_translation())
	var path = Array(navnode.get_simple_path(start, tgt, true))
	if path.size() > 0:
		var le = path.size() - 1
		direction = (path[le] - c.get_translation()).normalized()
		var steerv = c.get_transform().xform_inv(path[le])
		var steer = -steerv.normalized().x
		c.dval = steer
	else:
		var dp = navnode.get_closest_point_to_segment(start, tgt)
		var pdp = c.get_translation().linear_interpolate(dp, 0.1)
		direction = (pdp - c.get_translation()).normalized()
		var steerv = c.get_transform().xform_inv(pdp)
		var steer = -steerv.normalized().x
		c.dval = steer

func _fixed_process(dt):
	for c in car_array:
		c["time"] -= dt
		if c["time"] <= 0.0:
			car_array.remove(car_array.find(c))
			get_parent().remove_child(c["car"])
			c["car"].queue_free()
		if c["car"].get_translation().y < -3.0:
			car_array.remove(car_array.find(c))
			get_parent().remove_child(c["car"])
			c["car"].queue_free()
		set_car_direction(c["car"])
	if pass_time >= spawn_period + randf() / 3.0:
		if spawn_col.get_overlapping_bodies().size() == 0:
			if car_array.size() < car_limit:
				var mcar = spawn_car()
#				mcar.set_name("car" + str(car_array.size()))
				car_array.append({"car": mcar, "time": life_time})
				pass_time = 0.0
	else:
		pass_time += dt



