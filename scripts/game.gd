extends Node2D

@onready var player_scene = preload('res://scenes/player.tscn')
@onready var bot_scene = preload('res://scenes/bot.tscn')

func _ready():
	# spawn cats
	g.players['p1'] = player_scene.instantiate()
	g.players['p1'].global_position = $P1Spawn.global_position
	g.players['p1'].player = 'p1'
	add_child(g.players['p1'])
	#p2 = bot_scene.instantiate() if g.player_input_devices['p2'] == 'bot' else player_scene.instantiate()
	g.players['p2'] = bot_scene.instantiate() if g.player_input_devices['p2'] == 'bot' else g.players['p1'].duplicate()
	g.players['p2'].global_position = $P2Spawn.global_position
	g.players['p2'].player = 'p2'
	add_child(g.players['p2'])
	# update boxes to match correct cat
	var p1Box = get_node('HUD/p1Box')
	p1Box.select('p1_no_label')
	p1Box.set_cat(g.p1_cat)
	# TODO: set p1 cat sprite
	var p2Box = get_node('HUD/p2Box')
	p2Box.select('p2_no_label')
	if g.p2_cat == 'random':
		var rng = RandomNumberGenerator.new()
		g.p2_cat = str(rng.randi_range(1, 8))
	p2Box.set_cat(g.p2_cat)
	# TODO: set p2 cat sprite

func change_hp_bar(player: String, new_hp):
	get_node('HUD/'+player+'ProgressBar').value = new_hp
