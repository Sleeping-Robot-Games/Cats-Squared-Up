extends CharacterBody2D

var player = 'p1'
var is_crouching: bool = false
var is_jumping: bool = false
var is_floating: bool = false
var is_moving_left: bool = false
var is_moving_right: bool = false
var is_flipped: bool = false
var is_disabled = false
var input_buffer: Array = []
var input_window: float = 0.1
var time: float = input_window
var hp: int = 100
var hit_enemies: Array = []

const JUMP_SPEED: float = 200.0
const FALL_SPEED: float = 200.0
const MOVE_SPEED: float = 200.0
const HIT_SPEED: float = 200.0
const BASE_DMG: int = 5

@onready var game = get_parent()
@onready var state_machine = $AnimationTree.get('parameters/playback')

var common_moves: Dictionary = g.moves['common']

func _ready():
	var is_p1 = player == 'p1'
	set_collision_layer_value(1, is_p1)
	set_collision_layer_value(2, !is_p1)
	$HitArea.set_collision_layer_value(1, is_p1)
	$HitArea.set_collision_layer_value(2, !is_p1)
	$HitArea.set_collision_mask_value(1, !is_p1)
	$HitArea.set_collision_mask_value(2, is_p1)

func _input(event):
	if not correct_input(event):
		return
	# TODO only allow UI interaction if disabled
	if is_disabled:
		return
	# punch
	if event.is_action_pressed('keyboard_punch') \
	or event.is_action_pressed('joypad_punch'):
		time = input_window
		input_buffer.append('punch')
		return
	# kick
	if event.is_action_pressed('keyboard_kick') \
	or event.is_action_pressed('joypad_kick'):
		time = input_window
		input_buffer.append('kick')
		return
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
	# walk / idle / jump / crouch / smash
	if is_on_floor():
		var state = state_machine.get_current_node()
		var walk_left = 'walk_forward' if is_flipped else 'walk_backward'
		var walk_right = 'walk_backward' if is_flipped else 'walk_forward'
		if is_moving_left and (state == 'idle' or walk_right):
			var anim = walk_left
			state_machine.travel(anim)
		elif is_moving_right and (state == 'idle' or walk_left):
			var anim = walk_right
			state_machine.travel(anim)
		elif !is_moving_left and state == walk_left:
			state_machine.travel('idle')
		elif !is_moving_right and state == walk_right:
			state_machine.travel('idle')
		elif event.is_action_pressed('keyboard_up') \
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
		elif is_moving_left and is_crouching:
			# TODO fix
			print('crouch_block')
			state_machine.travel('crouch_block')
		elif event.is_action_pressed('keyboard_smash') \
		or event.is_action_pressed('joypad_smash'):
			state_machine.travel('cat_smash')

func correct_input(event) -> bool:
	if (event is InputEventKey and g.player_input_devices[player] == 'keyboard') \
	or (event is InputEventJoypadButton and g.player_input_devices[player] == 'joypad_' + str(event.device)):
		return true
	return false

func _process(delta: float):
	if is_disabled:
		return
	var state = state_machine.get_current_node()
	face_opponent()
	process_state(state)
	if(input_buffer.size() > 0):
		time -= delta
		if(time < 0):
			attempt_combo(input_buffer)
			time = input_window
			input_buffer.clear()
			return
	# apply velocity
	velocity = Vector2.ZERO
	if state == 'crouch_hit':
		velocity.x += (HIT_SPEED / 2) if is_flipped else (HIT_SPEED / 2) * -1
	elif state == 'straight_hit':
		velocity.x += HIT_SPEED if is_flipped else HIT_SPEED * -1
	elif state == 'jump_hit':
		velocity.x += HIT_SPEED if is_flipped else HIT_SPEED * -1
		velocity.y -= HIT_SPEED
	elif is_moving_left:
		velocity.x -= MOVE_SPEED
	elif is_moving_right:
		velocity.x += MOVE_SPEED
	# vertical
	if is_jumping:
		velocity.y -= JUMP_SPEED
	elif is_floating:
		velocity.y += FALL_SPEED / 2
	else:
		velocity.y += FALL_SPEED
	move_and_slide()

func face_opponent():
	var opponent = 'p2' if player == 'p1' else 'p1'
	var distance_to_opponent = g.players[opponent].global_position.x - g.players[player].global_position.x
	if distance_to_opponent > 20:
		scale.x = scale.y * 1
		is_flipped = false
	elif distance_to_opponent < -20:
		scale.x = scale.y * -1
		is_flipped = true

func process_state(state: String):
	if state == 'jump' and is_on_floor():
		is_jumping = true
	elif state == 'jump_punch' or state == 'jump_kick':
		is_jumping = false
		is_floating = true
	elif state == 'jump_fall':
		is_jumping = false
		is_floating = false
	if state == 'jump_fall' and is_on_floor():
		state_machine.travel('jump_land')

func attempt_combo(combo: Array = []):
	#print('combo: ', combo)
	var state = state_machine.get_current_node()
	if(combo.has('punch')):
		if is_crouching:
			state_machine.travel('crouch_punch')
			return
		elif state == 'jump' or state == 'jump_fall':
			state_machine.travel('jump_punch')
			return
		else:
			state_machine.travel('straight_punch')
			return
	elif(combo.has('kick')):
		if is_crouching:
			state_machine.travel('crouch_kick')
			return
		elif state == 'jump' or state == 'jump_fall':
			state_machine.travel('jump_kick')
			return
		else:
			state_machine.travel('straight_kick')
			return

# height = 'low' | 'mid' | 'high'
func dmg(num: int, height: String = 'mid'):
	var state = state_machine.get_current_node()
	if state == 'walk_backward' and height == 'mid':
		state_machine.travel('straight_block')
		print('blocked')
		return
	if is_on_floor():
		if is_crouching:
			state_machine.travel('crouch_hit')
		else:
			state_machine.travel('straight_hit')
	else:
		state_machine.travel('jump_hit')
	$Sprite.modulate = Color(1,0,0,1)
	$HitTimer.start()
	hp -= num
	if hp <= 0:
		hp = 0
		lose()
	game.change_hp_bar(player, hp)

func win():
	state_machine.travel('victory')
	var opponent = 'p2' if player == 'p1' else 'p1'
	is_disabled = true

func lose():
	state_machine.travel('defeat')
	var opponent = 'p2' if player == 'p1' else 'p1'
	g.players[opponent].win()
	game.match_winner(opponent)
	is_disabled = true

func _on_hit_area_body_entered(body):
	if !hit_enemies.has(body) and body.has_method('dmg'):
		hit_enemies.append(body)
		body.dmg(BASE_DMG)

func _on_hit_area_body_exited(body):
	if hit_enemies.has(body):
		hit_enemies.erase(body)


func _on_hit_timer_timeout():
	$Sprite.modulate = Color(1,1,1,1)
