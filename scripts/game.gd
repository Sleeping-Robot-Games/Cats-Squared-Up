extends Node2D

@onready var player_scene = preload('res://scenes/player.tscn')
var p1 = null
var p2 = null

func _ready():
	p1 = player_scene.instantiate()
	p1.global_position = $P1Spawn.global_position
	p1.player = 'p1'
	add_child(p1)
	p2 = player_scene.instantiate()
	p2.global_position = $P2Spawn.global_position
	p2.player = 'p2'
	add_child(p2)
