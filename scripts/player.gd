extends CharacterBody2D

var player = 'p1'
var is_crouching: bool = false
var is_jumping: bool = false
var is_moving_left: bool = false
var is_moving_right: bool = false
var input_buffer: Array = []
var input_window: float = 0.2
var time: float = input_window

const JUMP_SPEED: float = 200.0
const FALL_SPEED: float = 200.0
const MOVE_SPEED: float = 200.0

@onready var state_machine = $AnimationTree.get('parameters/playback')

var common_moves: Dictionary = g.moves['common']

func _input(event):
	if not correct_input(event):
		return
	# punch
	if event.is_action_pressed('keyboard_punch') \
	or event.is_action_pressed('joypad_punch'):
		time = input_window
		input_buffer.append('punch')
		return
	# jump / crouch / idle
	if is_on_floor():
		if event.is_action_pressed('keyboard_up') \
		or event.is_action_pressed('joypad_up'):
			state_machine.travel('jump')
		elif event.is_action_pressed('keyboard_down') \
		or event.is_action_pressed('joypad_down'):
			is_crouching = true
			state_machine.travel('crouch_idle')
		elif event.is_action_released('keyboard_down') \
		or event.is_action_released('joypad_down'):
			is_crouching = false
			state_machine.travel('idle')
	# moving left
	if event.is_action_pressed('keyboard_left') \
	or event.is_action_pressed('joypad_left'):
		is_moving_left = true
	elif event.is_action_released('keyboard_left') \
	or event.is_action_released('joypad_left'):
		is_moving_left = false
	# moving right
	if event.is_action_pressed('keyboard_right') \
	or event.is_action_pressed('joypad_right'):
		is_moving_right = true
	elif event.is_action_released('keyboard_right') \
	or event.is_action_released('joypad_right'):
		is_moving_right = false

func correct_input(event) -> bool:
	if (event is InputEventKey and g.player_input_devices[player] == 'keyboard') \
	or (event is InputEventJoypadButton and g.player_input_devices[player] == 'joypad_' + str(event.device)):
		return true
	return false

func _process(delta: float):
	process_state(state_machine.get_current_node())
	if(input_buffer.size() > 0):
		time -= delta
		if(time < 0):
			attempt_combo(input_buffer)
			time = input_window
			input_buffer.clear()
			return
	# apply velocity
	velocity = Vector2.ZERO
	if is_moving_left:
		velocity.x -= MOVE_SPEED
	elif is_moving_right:
		velocity.x += MOVE_SPEED
	if is_jumping:
		velocity.y -= JUMP_SPEED
	else:
		velocity.y += FALL_SPEED
	move_and_slide()

func process_state(state: String):
	if state == 'jump' and is_on_floor():
		is_jumping = true
	elif state == 'jump_fall':
		is_jumping = false
	if state == 'jump_fall' and is_on_floor():
		state_machine.travel('jump_land')

func attempt_combo(combo: Array = []):
	print('combo: ', combo)
	if(combo.has('punch')):
		if is_crouching:
			state_machine.travel('crouch_punch')
			return
		else:
			state_machine.travel('straight_punch')
			return
