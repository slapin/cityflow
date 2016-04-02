
extends AnimationTreePlayer

# member variables here, example:
# var a=2
# var b="textvar"

var origpos

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	var p = get_parent()
	origpos = p.get_global_transform().origin
	origpos.y = 0
	set_fixed_process(true)

var oldstate = -1
func _fixed_process(dt):
	var p = get_parent()
	if p == null:
		return
	if true:
		if oldstate != p.state:
			oldstate = p.state
			if p.state == p.WALK:
				var pv = p.get_global_transform().origin
				pv.y = 0
				var vel = pv - origpos
				var data = clamp(vel.length() / (p.speed * 200.0), 0.0, 1.0)
				blend2_node_set_amount("idle_walk", data)
			elif p.state == p.IDLE:
				blend2_node_set_amount("idle_walk", 0.0)
			


