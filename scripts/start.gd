extends Node2D

func _ready():
	$Join/JoinKeys.play()

func _input(event):
	if event is InputEvent and event.is_action_pressed("keyboard_submit"):
		g.player_input_devices['p1'] = 'keyboard'
		$MenuYes.play()
		$CatSelectTimer.start()
	elif event is InputEventJoypadButton and event.is_action_pressed("joypad_submit"):
		var device_name: String = Input.get_joy_name(event.device)
		if g.ghost_inputs.has(device_name):
			return
		g.player_input_devices['p1'] = 'joypad_' + str(event.device)
		$MenuYes.play()
		$CatSelectTimer.start()

func _on_cat_select_timer_timeout():
	get_tree().change_scene_to_file("res://scenes/character_select.tscn")
