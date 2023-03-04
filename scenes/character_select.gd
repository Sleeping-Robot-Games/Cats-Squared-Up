extends Node2D

var p1_cat
var p2_cat
var p1_color: Color = Color(0.83, 0.44, 0.36)

func _ready():
	for cat in $Cats.get_children():
		cat.get_node('Button').button_up.connect(_on_cat_select.bind(cat.name.right(1)))

func _on_cat_select(num: String):
	if p1_cat != null:
		# Set old color to transparent
		p1_cat.color.a8 = 0
	p1_cat = get_node("Cats/Cat" + num)
	p1_cat.color = p1_color
	# TODO: put p1_cat details into global state to start the game?
	
# TODO: Implement focus change with controller for p2
## maybe a simple int that increments/decrements and skips over current p1 cat

func _on_fight_button_up():
	# Check to make sure the player cat info is in global state before continuing
	get_tree().change_scene_to_file("res://scenes/game.tscn")
