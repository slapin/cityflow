
extends Spatial

# member variables here, example:
# var a=2
# var b="textvar"

#onready var car = load("res://vehicles/meta-car.scn")
#onready var place = get_node("car-spawn").get_translation()
#onready var roll = get_node("car-spawn").get_rotation()
#onready var spawn_col = get_node("car-spawn/col")

#func spawn_car():
#	var car_inst = car.instance()
#	add_child(car_inst)
#	car_inst.set_translation(place)
#	car_inst.set_rotation(roll)
#	car_inst.set_engine_force(200.0 + 300.0 * randf())
#	car_inst.set_engine_force(0.0)
#	car_inst.switch_state(car_inst.SPEEDING)

onready var navnode = get_node("nav")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
#	pass
#	spawn_car()
	set_fixed_process(true)


#var pass_time = 0
#var spawn_period = 0.01

#func _process(dt):
#	if pass_time >= spawn_period + randf() / 3.0:
#		if spawn_col.get_overlapping_bodies().size() == 0:
#			spawn_car()
#			pass_time = 0.0
#	else:
#		pass_time += dt
