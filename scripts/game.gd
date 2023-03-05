extends Node2D

@onready var player_scene = preload('res://scenes/player.tscn')
@onready var bot_scene = preload('res://scenes/bot.tscn')

func _ready():
	g.players['p1'] = player_scene.instantiate()
	g.players['p1'].global_position = $P1Spawn.global_position
	g.players['p1'].player = 'p1'
	add_child(g.players['p1'])
	#p2 = bot_scene.instantiate() if g.player_input_devices['p2'] == 'bot' else player_scene.instantiate()
	g.players['p2'] = bot_scene.instantiate() if g.player_input_devices['p2'] == 'bot' else g.players['p1'].duplicate()
	g.players['p2'].global_position = $P2Spawn.global_position
	g.players['p2'].player = 'p2'
	add_child(g.players['p2'])
