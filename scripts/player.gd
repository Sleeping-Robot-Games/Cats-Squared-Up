extends CharacterBody2D

var input_window: float = 0.2
var time: float = input_window
var is_crouching: bool = false
var input_buffer: Array = []

@onready var anim_tree = $AnimationTree.get("parameters/playback")

var common_moves: Dictionary = m.moves["common"]

func _input(event):
	var is_punching = false
	if (event is InputEventKey and event.is_action_just_pressed("keyboard_punch")) \
	or (event is InputEventJoypadButton and event.is_action_pressed("joypad_punch")):
		is_punching = true
	
	if is_punching:
		time = input_window
		input_buffer.append("punch")
		return
	#if event is InputEventKey:
		# if input made, only signal it once
	#	if event.pressed and not event.echo:
	#		var keycode = OS.get_keycode_string(event.keycode)
			# ensure valid key
	#		if "WASDL".find(keycode) >= 0:
	#			time = input_window
	#			input_buffer.append(keycode)
	#			return

func _process(delta):
	if(input_buffer.size() > 0):
		time -= delta
		if(time < 0):
			attempt_combo(input_buffer)
			time = input_window
			input_buffer.clear()
			return
	
	# TODO: device mapping
	if(Input.is_action_pressed("keyboard_down") or Input.is_action_pressed("joypad_down")):
		anim_tree.travel("crouch")
		is_crouching = true
		return
	else:
		anim_tree.travel("idle")
		is_crouching = false
		return

func attempt_combo(combo: Array = []):
	print("combo: ", combo)
	if(combo.has("punch")):
		if is_crouching:
			print("crouch_punch")
			anim_tree.travel("crouch_punch")
			return
		else:
			print("straight_punching")
			anim_tree.travel("straight_punch")
			return
