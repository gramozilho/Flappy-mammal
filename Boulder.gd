extends Area2D


signal hit


var on_color = Color(1.0, 1.0, 1.0, 1.0)
var off_color = Color(1.0, 1.0, 1.0, 0.0)
var on_timer = 1
var off_timer = 3

var boulder_speed_default = 100
export var boulder_speed = 100

onready var tween = get_node("Tween")


func _ready():
	$Sprite.modulate = off_color
	set_physics_process(true)


func _physics_process(delta):
	global_position.x -= boulder_speed * delta


func _on_Boulder_body_entered(body):
	#print('Hit detected with body ', body)
	emit_signal("hit")
	tween.stop_all()
	tween.interpolate_property($Sprite, "modulate", $Sprite.modulate, 
	on_color, 2, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.start()


func _on_Boulder_area_entered(area):
	#change_color($Sprite.modulate, on_color, 'on')
	tween.stop_all()
	tween.interpolate_property($Sprite, "modulate", $Sprite.modulate, 
	on_color, on_timer, Tween.TRANS_EXPO, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_completed")
	tween.interpolate_property($Sprite, "modulate", $Sprite.modulate, 
	off_color, off_timer, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()

func start_moving():
	boulder_speed = boulder_speed_default

func freeze():
	boulder_speed = 0
