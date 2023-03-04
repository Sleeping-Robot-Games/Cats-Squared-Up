extends CharacterBody2D

var input_window: float = 0.2
var time: float = input_window
var is_crouching: bool = false
var input_buffer: Array = []

@onready var anim_tree = $AnimationTree.get("parameters/playback")

var common_moves: Dictionary = m.moves["common"]

func _input(event):
	if event is InputEventKey:
		# if input made, only signal it once
		if event.pressed and not event.echo:
			var keycode = OS.get_keycode_string(event.keycode)
			# ensure valid key
			if "WASDL".find(keycode) >= 0:
				time = input_window
				input_buffer.append(keycode)
				return

func _process(delta):
	if(input_buffer.size() > 0):
		time -= delta
		if(time < 0):
			attempt_combo(input_buffer)
			time = input_window
			input_buffer.clear()
			return
	
	if(Input.is_action_pressed("down")):
		anim_tree.travel("crouch")
		is_crouching = true
		return
	else:
		anim_tree.travel("idle")
		is_crouching = false
		return

func attempt_combo(combo: Array = []):
	if(combo.has("L")):
		if is_crouching:
			anim_tree.travel("straight_punch")
		else:
			anim_tree.travel("crouch_punch")
