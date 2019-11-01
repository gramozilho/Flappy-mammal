extends Node2D

var boulder_slots = 15
var y_size = 600

var boulder_speed = 100
var boulder_x_spawn = 1100
var gap_size = 10

var boulder_measures
var max_y_slots = [0, boulder_slots]
var y_slots = [0, boulder_slots]

var tutorial_step = 0
var y_coord = [0, 600]
var level_up_time = 10

var time_start

onready var boulder = load("res://Boulder.tscn")
onready var tween = get_node("Label/TextTween")

# Called when the node enters the scene tree for the first time.
func _ready():
	boulder_measures = []
	for i in range(boulder_slots+1):
		boulder_measures.append(i * y_size / (boulder_slots))
	# Connect all boulders to main
	for boulder in get_tree().get_nodes_in_group("boulder"):
		boulder.connect("hit", self, "player_got_hit")
	
	$RestartButton.visible = false
	$Jukebox.play()
	
	# Handle score
	$ScoreLabel.visible = false

func _input(event):
	if event.is_action_pressed('ui_accept') and tutorial_step == 0:
		tutorial_step = 1
		# Allow the player to move
		$Bat.game_state = "game"
		# Add velocity to scene boulders
		get_tree().call_group("boulder", "start_moving")
		
		# Start boulder timer
		$BoulderSpawn.start()
		$IncreaseLevel.wait_time = level_up_time
		
		# Hide instructions
		tween.interpolate_property($Label, "modulate", $Label.modulate, 
		Color(1.0, 1.0, 1.0, 0.0), 3 , Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.start()
		
		$IncreaseLevel.set_wait_time(level_up_time)
		$IncreaseLevel.start()
		time_start = OS.get_unix_time()

func _on_DeleteArea_area_entered(area):
	area.queue_free()


func _on_BoulderSpawn_timeout():
	
	# Spawn boulders
	y_coord = [boulder_measures[y_slots[0]], boulder_measures[y_slots[1]]]
	for coord in y_coord:
		var boulder_instance = boulder.instance()
		boulder_instance.boulder_speed = boulder_speed
		boulder_instance.global_position = Vector2(boulder_x_spawn, coord)
		# Add random overlapping
		boulder_instance.z_index = randi()%5+1
		# Add random rotation
		boulder_instance.rotation_degrees = randi()%360
		# Slightly alter size
		boulder_instance.scale.x *= 1 + (randf()-.5)/3
		boulder_instance.scale.y *= 1 + (randf()-.5)/3
		boulder_instance.connect("hit", self, "player_got_hit")
		add_child(boulder_instance)
		
	# Decide y coordinates
	
	y_slots[0] = max(y_slots[0] + randi()%5-2, max_y_slots[0])
	y_slots[1] = min(y_slots[1] + randi()%5-2, max_y_slots[1])
	# Change one side to assure bigger than mandatory gap
	var flip = true
	while y_slots[1]-y_slots[0] < gap_size:
		if flip and y_slots[0]>max_y_slots[0]:  # y_slots[0]>1:
			y_slots[0] -= 1 #y_slots[1] - gap_size
		elif !flip and y_slots[1]<max_y_slots[1]:
			y_slots[1] += 1 # y_slots[1] + gap_size
		flip = !flip


func player_got_hit():
	$Die.play()
	$Bat.game_state = "freeze"
	$BoulderSpawn.stop()
	get_tree().call_group("boulder", "freeze")
	$RestartButton.visible = true
	tween.interpolate_property($Jukebox, "volume_db", $Jukebox.volume_db, 
	-50, 3 , Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	# Score screen
	$ScoreLabel.visible = true
	$ScoreLabel.text = "Score: " + String(OS.get_unix_time() - time_start)
	# Briefly turn screen red
	tween.interpolate_property($CanvasModulate, "color", Color(.5, .2, .2, 1.0), 
	Color(1.0, 1.0, 1.0, 1.0), .5, Tween.TRANS_BACK, Tween.EASE_IN)
	tween.start()


func _on_RestartButton_pressed():
	get_tree().reload_current_scene()


func _on_IncreaseLevel_timeout():
	#$Jukebox.pitch_scale *= 1.01
	tween.interpolate_property($Jukebox, "pitch_scale", $Jukebox.pitch_scale, 
	$Jukebox.pitch_scale*1.01, level_up_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	#boulder_speed *= 1.1
	tween.interpolate_property(self, "boulder_speed", boulder_speed, 
	boulder_speed*1.2, level_up_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	#$BoulderSpawn.set_wait_time($BoulderSpawn.wait_time/1.1)
	tween.interpolate_property($BoulderSpawn, "wait_time", 
	$BoulderSpawn.wait_time, $BoulderSpawn.wait_time/1.2, 
	level_up_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	
	print('Increase difficulty')
	gap_size -= .1
