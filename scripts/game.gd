extends Node2D

@onready var player_scene = preload('res://scenes/player.tscn')
@onready var bot_scene = preload('res://scenes/bot.tscn')

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
