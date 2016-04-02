
extends Spatial

# member variables here, example:
# var a=2
# var b="textvar"

onready var char = load("res://characters/lpman-ctrl.scn")
onready var place = get_global_transform()
onready var roll = get_rotation()
onready var spawn_col = get_node("col")
onready var target = get_node("target")

var ped_limit = 10
func spawn_character():
	var char_inst = char.instance()
	get_parent().add_child(char_inst)
	char_inst.set_global_transform(place)
	char_inst.state = char_inst.WALK
	char_inst.speed = 0.5 + randf() * 2.5
	return char_inst

var char_array = []
var life_time = 240.0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	var mchar = spawn_character()
#	mcar.set_name("car" + str(car_array.size()))
#	car_array.append({"car": mcar, "time": life_time})
	set_fixed_process(true)


var spawn_period = 2.5
var pass_time = spawn_period

func set_char_direction(c):
#	var direction = c.get_transform().basis[2]
	var tgt = target.get_global_transform().origin
	
#	var ct = c.get_transform()
#	var cct = ct.looking_at(tgt, Vector3(0.0, 1.0, 0.0))
#	var q1 = Quat(ct.basis)
#	var q2 = Quat(cct.basis)
#	var q = q1.slerp(q2, 0.1)
#	var mt = Transform(q)
#	mt.origin = cct.origin
#	c.set_transform(mt)
	c.target = tgt

func _fixed_process(dt):
	for c in char_array:
		c["time"] -= dt
		if c["time"] <= 0.0:
			char_array.remove(char_array.find(c))
			get_parent().remove_child(c["char"])
			c["char"].queue_free()
		if c["char"].get_translation().y < -3.0:
			char_array.remove(char_array.find(c))
			get_parent().remove_child(c["char"])
			c["char"].queue_free()
		set_char_direction(c["char"])
	if pass_time >= spawn_period + randf() / 3.0:
		if spawn_col.get_overlapping_bodies().size() == 0:
			if char_array.size() < ped_limit:
				var mchar = spawn_character()
#				mcar.set_name("car" + str(car_array.size()))
				char_array.append({"char": mchar, "time": life_time})
				pass_time = 0.0
	else:
		pass_time += dt



