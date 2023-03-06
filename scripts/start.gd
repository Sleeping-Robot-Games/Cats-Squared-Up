extends Node2D

var is_starting = false
var is_splash = true

func _ready():
	$JoinKeys.play()

func _input(event):
	if is_starting or is_splash:
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

func splash_done():
	print('splash_done')
	$Splash.visible = false
	is_splash = false


func _on_timer_timeout():
	#var tween = get_tree().create_tween()
	#tween.tween_property($Splash, "modulate:a", 3, 0)
	#tween.tween_callback(splash_done)
	pass


func _on_start_timer_timeout():
	$Splash/AnimatedSprite.play()
	#$Splash/Timer.start()


func _on_animated_sprite_animation_finished():
	var tween = get_tree().create_tween()
	tween.tween_property($Splash, "modulate:a", 3, 0)
	tween.tween_callback(splash_done)
