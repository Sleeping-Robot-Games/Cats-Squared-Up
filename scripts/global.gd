extends Node

var p1_cat: String = '1'
var p2_cat: String = 'random'

var player_input_devices: Dictionary = {
	'p1': 'keyboard',
	'p2': 'bot',
}

# physical input duplicate entries
var ghost_inputs: Array = ['Steam Virtual Gamepad']

var common_moves: Dictionary = {
	'punch': 'punch'
}

var moves: Dictionary = {
	'common': common_moves
}
