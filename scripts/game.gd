extends Node2D

@onready var player_scene = preload('res://scenes/player.tscn')
@onready var bot_scene = preload('res://scenes/bot.tscn')

var match_over: bool = false
var restart_focused: bool = false

func _ready():
	# init cats
	g.players['p1'] = player_scene.instantiate()
	g.players['p1'].global_position = $P1Spawn.global_position
	g.players['p1'].player = 'p1'
	g.players['p2'] = bot_scene.instantiate() if g.player_input_devices['p2'] == 'bot' else g.players['p1'].duplicate()
	g.players['p2'].global_position = $P2Spawn.global_position
	g.players['p2'].player = 'p2'
	# update boxes to appropriate cat
	var p1Box = get_node('HUD/p1Box')
	p1Box.select('p1_no_label')
	p1Box.set_cat(g.p1_cat)
	var p2Box = get_node('HUD/p2Box')
	p2Box.select('p2_no_label')
	if g.p2_cat == 'random':
		var total_cats = 3 # TODO: increase as other cats are unlocked
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var cat_num = rng.randi_range(1, total_cats)
		# if random cat matches opponent, increment by 1
		if str(cat_num) == g.p1_cat:
			g.p2_cat = str(cat_num + 1) if cat_num < total_cats else '1'
		else:
			g.p2_cat = str(cat_num)
	p2Box.set_cat(g.p2_cat)
	# update sprites to appropriate cat
	g.players['p1'].get_node('Sprite').texture = load('res://assets/'+g.cat_names[g.p1_cat]+'.png')
	g.players['p2'].get_node('Sprite').texture = load('res://assets/'+g.cat_names[g.p2_cat]+'.png')
	# add cats to game
	add_child(g.players['p1'])
	add_child(g.players['p2'])

func change_hp_bar(player: String, new_hp):
	get_node('HUD/'+player+'ProgressBar').value = new_hp

func match_winner(player: String):
	match_over = true
	var p1_win = player == 'p1'
	$HUD/MatchOver/p1Victory.visible = p1_win
	$HUD/MatchOver/p2Victory.visible = !p1_win
	restart_focused = true
	$HUD/MatchOver/Restart.grab_focus()
	$HUD/MatchOver.visible = true

func _input(event):
	# match over button interactions
	if not match_over:
		return
	if event is InputEvent and g.player_input_devices['p1'] == 'keyboard':
		if event.is_action_pressed('keyboard_ui_up') \
		or event.is_action_pressed('keyboard_ui_down') \
		or event.is_action_pressed('keyboard_ui_left') \
		or event.is_action_pressed('keyboard_ui_right'):
			match_over_focus_changed()
		elif event.is_action_pressed('keyboard_select') \
		or event.is_action_pressed('keyboard_submit'):
			match_over_button_pressed()
	elif event is InputEventJoypadButton \
	and g.player_input_devices['p1'] == 'joypad_' + str(event.device) \
	and !g.ghost_inputs.has(Input.get_joy_name(event.device)):
			if event.is_action_pressed('joypad_up') \
			or event.is_action_pressed('joypad_down') \
			or event.is_action_pressed('joypad_left') \
			or event.is_action_pressed('joypad_right'):
				match_over_focus_changed()
			elif event.is_action_pressed('joypad_select') \
			or event.is_action_pressed('joypad_submit'):
				match_over_button_pressed()

func match_over_focus_changed():
	restart_focused = !restart_focused
	if restart_focused:
		$HUD/MatchOver/Restart.grab_focus()
	else:
		$HUD/MatchOver/Quit.grab_focus()

func match_over_button_pressed():
	$MenuYes.play()
	# TODO: small delay
	if g.player_input_devices['p2'] == 'bot':
		g.p2_cat = 'random'
	g.players['p1'] = null
	g.players['p2'] = null
	if restart_focused:
		#get_tree().reload_current_scene()
		get_tree().change_scene_to_file('res://scenes/character_select.tscn')
	else:
		get_tree().change_scene_to_file('res://scenes/start.tscn')
