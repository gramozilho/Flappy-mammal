extends Node2D

var boulder_slots = 30
var y_size = 600

var boulder_speed = 100
var boulder_x_spawn = 1100
var gap_size = 18

var boulder_measures
var max_y_slots = [0, boulder_slots]
var y_slots = max_y_slots

var tutorial_step = 0

onready var boulder = load("res://Boulder.tscn")
onready var tween = get_node("Label/TextTween")

# Called when the node enters the scene tree for the first time.
func _ready():
	boulder_measures = []
	for i in range(boulder_slots):
		boulder_measures.append(i * y_size / (boulder_slots-1))


func _input(event):
	if event.is_action_pressed('ui_accept') and tutorial_step == 0:
		tutorial_step = 1
		tutorial_step = 1
		# Allow the player to move
		$Bat.game_state = "game"
		# Add velocity to scene boulders
		get_tree().call_group("boulder", "start_moving")
		
		# Start boulder timer
		$BoulderSpawn.start()
		
		# Hide instructions
		tween.interpolate_property($Label, "modulate", $Label.modulate, 
		Color(1.0, 1.0, 1.0, 0.0), 3 , Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.start()


func _on_DeleteArea_area_entered(area):
	area.queue_free()


func _on_BoulderSpawn_timeout():
	# Decide y coordinates
	var y_coord = [0, 600]
	y_slots[0] = max(y_slots[0] + randi()%5-2, max_y_slots[0])
	y_slots[1] = min(y_slots[1] + randi()%5-2, max_y_slots[1])
	# Change one side to assure bigger than mandatory gap
	if y_slots[1]-y_slots[0] < gap_size:
		if y_slots[0]>1:
			y_slots[0] -= 2 #y_slots[1] - gap_size
		else:
			y_slots[1] += 2 # y_slots[1] + gap_size
	
	# Spawn boulders
	y_coord = [boulder_measures[y_slots[0]], boulder_measures[y_slots[1]]]
	for coord in y_coord:
		var boulder_instance = boulder.instance()
		boulder_instance.global_position = Vector2(boulder_x_spawn, coord)
		# Add random overlapping
		boulder_instance.z_index = randi()%5+1
		# Add random rotation
		boulder_instance.rotation_degrees = randi()%360
		# Slightly alter size
		boulder_instance.scale.x *= 1 + (randf()-.5)/3
		boulder_instance.scale.y *= 1 + (randf()-.5)/3
		add_child(boulder_instance)
