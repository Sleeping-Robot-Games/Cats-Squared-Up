extends Node

var players: Dictionary = {
	'p1': null,
	'p2': null
}

var p1_cat: String = '1'
var p2_cat: String = 'random'

var player_input_devices: Dictionary = {
	'p1': 'keyboard',
	'p2': 'bot',
}

var cat_names: Dictionary = {
	'1': 'pretty',
	'2': 'atlas',
	'3': 'monkey',
	'4': 'faye',
	'5': 'toad',
	'6': 'jaime',
}

# physical input duplicate entries
var ghost_inputs: Array = ['Steam Virtual Gamepad']

var common_moves: Dictionary = {
	'punch': 'punch'
}

var moves: Dictionary = {
	'common': common_moves
}
