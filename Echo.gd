extends Area2D

export var speed = 400
export var growth = 1.01
export var timer = 3

var direction = Vector2()
var starting_color = Color(1.0, 1.0, 1.0, 1.0)
var ending_color = Color(1.0, 1.0, 1.0, 0.0)

func _ready():
	# Set direction speed on spawn
	pass
	# Load timer 
	$Timer.wait_time = timer
	$Timer.start()
	# Set to vanish with time
	var tween = get_node("Tween")
	tween.interpolate_property($Sprite, "modulate", starting_color, ending_color, timer, Tween.TRANS_SINE, Tween.EASE_IN)
	tween.start()
	set_physics_process(true)
	
func _physics_process(delta):
	# Move echo
	global_position += speed * direction * delta
	
	# Increase in size
	scale *= growth


func _on_Timer_timeout():
	queue_free()
