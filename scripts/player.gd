extends CharacterBody2D

var is_crouching: bool = false
var is_jumping: bool = false
var input_buffer: Array = []
var input_window: float = 0.2
var time: float = input_window

const JUMP_SPEED: float = 200.0
const FALL_SPEED: float = 200.0
const MOVE_SPEED: float = 200.0

@onready var anim_tree = $AnimationTree.get("parameters/playback")

var common_moves: Dictionary = m.moves["common"]

func _input(event):
	# TODO: device mapping per player
	if !(event is InputEventKey) and !(event is InputEventJoypadButton):
		return
	# punch
	if event.is_action_pressed("keyboard_punch") \
	or event.is_action_pressed("joypad_punch"):
		time = input_window
		input_buffer.append("punch")
		return
	# jump
	if is_on_floor():
		if event.is_action_pressed("keyboard_up") \
		or event.is_action_pressed("joypad_up"):
			anim_tree.travel("jump")

func _process(delta: float):
	if(input_buffer.size() > 0):
		time -= delta
		if(time < 0):
			attempt_combo(input_buffer)
			time = input_window
			input_buffer.clear()
			return
	if is_on_floor():
		# crouch / idle
		if Input.is_action_pressed("keyboard_down") \
		or Input.is_action_pressed("joypad_down"):
			is_crouching = true
			anim_tree.travel("crouch")
		else:
			is_crouching = false
			anim_tree.travel("idle")
	# movement / jumping
	velocity = Vector2.ZERO
	if Input.is_action_pressed("keyboard_left") \
	or Input.is_action_pressed("joypad_left"):
		velocity.x -= MOVE_SPEED
	elif Input.is_action_pressed("keyboard_right") \
	or Input.is_action_pressed("joypad_right"):
		velocity.x += MOVE_SPEED
	if is_jumping:
		velocity.y -= JUMP_SPEED
	else:
		velocity.y += FALL_SPEED
	move_and_slide()

func attempt_combo(combo: Array = []):
	print("combo: ", combo)
	if(combo.has("punch")):
		if is_crouching:
			anim_tree.travel("crouch_punch")
			return
		else:
			anim_tree.travel("straight_punch")
			return

func change_state(state: String):
	print("change_state: ", state)
	if state == "jump" and is_on_floor():
		print("jumping")
		is_jumping = true
	elif state == "fall":
		print("falling")
		is_jumping = false
