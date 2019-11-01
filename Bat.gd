extends KinematicBody2D

onready var tween = get_node("Tween")

var echo = load("res://Echo.tscn") as PackedScene
var velocity = Vector2()

const GRAVITY = 400
const UP_FORCE = -GRAVITY
const wing_max = .5
const wing_min = -1.0
const wing_time = .2

var screech_time = .5
var game_state = "intro"  # either intro, play of freeze

func _ready():
	$WingCenter/WingLeft.get_material().set_shader_param('wing_position', wing_min)
	$WingCenter/WingRight.get_material().set_shader_param('wing_position', wing_min)
	set_physics_process(true)


func start_game():
	set_physics_process(true)


func restart():
	get_tree().reload_current_scene()


func _physics_process(delta):
	if game_state == "freeze":
		velocity.y = 0
	elif game_state == "game":
		if global_position.y < 700:
			velocity.y += GRAVITY*delta*2
		else:
			velocity.y = 0
	if game_state != "freeze":
		if Input.is_action_just_pressed("ui_accept") and game_state == "game":
			flap_wings()
			
		if Input.is_action_just_pressed("left_click") and $Timer.is_stopped():
			# Reset timer
			$Timer.wait_time = screech_time
			$Timer.start()
			# Spawn soounds
			var new_echo = echo.instance()
			var mouse_direction = (get_global_mouse_position() - global_position).normalized()
			new_echo.direction = mouse_direction
			new_echo.global_position = global_position
			var temp_rot = get_global_mouse_position().angle_to_point(global_position)
			new_echo.rotation = temp_rot
			get_parent().add_child(new_echo)
			$Echo.play()
		
		move_and_slide(velocity, Vector2(0, -1))


func flap_wings():
	# Wait before reaching top position
	if $WingCenter/WingLeft.get_material().get_shader_param('wing_position') == wing_min:
		# Flap down and increase velocity
		$Jump.play()
		velocity.y = UP_FORCE
		for wing in [$WingCenter/WingLeft, $WingCenter/WingRight]:
			tween.interpolate_property(wing.get_material(), "shader_param/wing_position", 
			wing_min, wing_max, wing_time, Tween.TRANS_QUAD, Tween.EASE_IN)
			tween.start()
		yield(tween, 'tween_completed')
		# Go to top
		for wing in [$WingCenter/WingLeft, $WingCenter/WingRight]:
			tween.interpolate_property(wing.get_material(), "shader_param/wing_position", 
			wing_max, wing_min, wing_time, Tween.TRANS_QUAD, Tween.EASE_OUT)
			tween.start()
	yield(tween, 'tween_completed')
