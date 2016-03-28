
extends Spatial

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

onready var car = get_node("car")



func _on_Button_pressed():
	car.set_steering(0.3)

func _on_Button_2_pressed():
	car.set_steering(-0.3)




func _on_Button_3_pressed():
	 car.set_steering(0.0)

func _on_Button_4_pressed():
	car.set_engine_force(40)
	car.set_brake(0)
