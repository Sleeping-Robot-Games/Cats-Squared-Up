extends Node2D

var is_starting = false

func _ready():
	$JoinKeys.play()

func _input(event):
	if is_starting:
		return
	if event is InputEvent and event.is_action_pressed('keyboard_submit'):
		g.player_input_devices['p1'] = 'keyboard'
		start()
	elif event is InputEventJoypadButton and event.is_action_pressed('joypad_submit'):
		var device_name: String = Input.get_joy_name(event.device)
		if g.ghost_inputs.has(device_name):
			return
		g.player_input_devices['p1'] = 'joypad_' + str(event.device)
		start()

func start():
	$JoinKeys.stop()
	$JoinKeys.frame = 2
	$Meow.play()
	$CatSelectTimer.start()
	is_starting = true

func _on_cat_select_timer_timeout():
	get_tree().change_scene_to_file('res://scenes/character_select.tscn')
