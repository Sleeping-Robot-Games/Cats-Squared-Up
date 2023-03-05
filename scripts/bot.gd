extends CharacterBody2D

var generator = RandomNumberGenerator.new()

var player = 'p2'

var offset_till_flip: int = 20 # How much overlap until the AI will flip 
var ai_movement_speed: int = 150 # How fast can the AI move
var move_dir # Current move direction of the AI
var max_distance = 300 # When the AI is too far away from the target
var max_move_time: float = 1 # Max allowed move time
var time: float = max_move_time # Current time until AI stops moving
var max_time_till_choice: float = 1.2 # Max waiting time until the next choice
var countdown: float = max_time_till_choice # Current time until next choice
var m_keys = ['straight_punch', 'straight_kick', 'cat_smash']
var start_moving = false # check if AI is allowed to move
var is_crouching = false # check if the AI isn't crouching
var is_attacking = false # check if AI is attacking

var hp: int = 100
var hit_enemies: Array = []
const BASE_DMG: int = 5
const FALL_SPEED: float = 200.0
const HIT_SPEED: float = 200.0

@onready var state_machine = $AnimationTree.get('parameters/playback')
@onready var player_node = get_parent().get_node("Player")
@onready var game = get_parent()

func _ready():
	var is_p1 = player == 'p1'
	set_collision_layer_value(1, is_p1)
	set_collision_layer_value(2, !is_p1)
	$HitArea.set_collision_layer_value(1, is_p1)
	$HitArea.set_collision_layer_value(2, !is_p1)
	$HitArea.set_collision_mask_value(1, !is_p1)
	$HitArea.set_collision_mask_value(2, is_p1)
	
func _process(delta):
	countdown -= delta
	
	face_player()  # Make sure the AI always faces the player
	
	# getting hit
	var state = state_machine.get_current_node()
	#print("bot state: " + state)
	if state.ends_with('_hit'):
		velocity = Vector2.ZERO
		if state == 'crouch_hit':
			velocity.x += (HIT_SPEED / 2) if scale.x > 0 else (HIT_SPEED / 2) * -1
		elif state == 'straight_hit':
			velocity.x += HIT_SPEED if scale.x > 0 else HIT_SPEED * -1
		elif state == 'jump_hit':
			velocity.x += HIT_SPEED if scale.x > 0 else HIT_SPEED * -1
			velocity.y -= HIT_SPEED
		move_and_slide()
		return
	
	# TODO
	# vertical
	#if is_jumping:
	#	velocity.y -= JUMP_SPEED
	#elif is_floating:
	#	velocity.y += FALL_SPEED / 2
	#else:
	#	velocity.y += FALL_SPEED
	if !is_on_floor():
		velocity.y += FALL_SPEED
		move_and_slide()
	
	if(!is_attacking && countdown < 0):
		choose_action()
	
	# Start moving
	if(start_moving && time > 0 && !is_crouching):
		move_ai()
		time -= delta
	else:
		start_moving = false
		time = max_move_time

func choose_action():
	var percentage_per_step = float(100) / float(max_distance) # Get the percentage increase with each step
	
	var chance = percentage_per_step * (abs(player_node.position.x - position.x)) # Calculate the actual chance that the AI has of its current distance from the player 
	chance = 100-clamp(chance, 10, 90) # Invert the scale so that, the closer the AI gets to the player the higher the outcome 
	
	if(return_random_value() <= chance): # Check if the return value between 0 to 100 is good enough for an attack  
		generator.randomize()
		var attack_value = generator.randi_range(0, m_keys.size() - 1)  # Pick from all possible moves what kind of attack is needed
		state_machine.travel(m_keys[generator.randi_range(0, m_keys.size() - 1)])
	else:
		start_moving = true
		time = max_move_time
		state_machine.travel('idle')
		set_crouch_state(false)
		
		# IF THE AI IS CROUCHING IT CAN'T MOVE 
	countdown = max_time_till_choice

func face_player():
	var distance_to_player = player_node.global_position.x - global_position.x # The place AI needs to go to - the place where it is = distance between the spots
	if(distance_to_player > offset_till_flip):    # AI comes from the left
		move_dir = 1
		scale.x = scale.y * move_dir
	elif(distance_to_player < -offset_till_flip):  # AI comes from the right
		move_dir = -1
		scale.x = scale.y * move_dir
	else:
		move_dir = 0
		
# Generate a random value between 0 to 100 and return it
func return_random_value():
	generator.randomize()
	return generator.randi_range(0, 100)

# A simple function that allows movement
func move_ai():
	velocity = Vector2()
	velocity.x += move_dir * ai_movement_speed
	state_machine.travel('walk_forward')
	move_and_slide()

func set_crouch_state(input):
	is_crouching = input

func set_attack_state(input):
	is_attacking = input
	z_index = 1
	player_node.z_index = 0

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
	hp -= num
	if hp <= 0:
		hp = 0
		# TODO death / lose
	game.change_hp_bar(player, hp)

func _on_hit_area_body_entered(body):
	if !hit_enemies.has(body) and body.has_method('dmg'):
		hit_enemies.append(body)
		body.dmg(BASE_DMG)

func _on_hit_area_body_exited(body):
	if hit_enemies.has(body):
		hit_enemies.erase(body)
