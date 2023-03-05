extends Node2D

var ready_state: Dictionary = {
	"p1": false,
	"p2": true
}
var focus: Dictionary = {
	"p1": Vector2(0,0),
	"p2": Vector2(0,3)
}
@onready var cats: Array = [
	[$Cats/Cat1, $Cats/Cat2, $Cats/Cat3, $Cats/Cat4],
	[$Cats/Cat5, $Cats/Cat6, $Cats/Cat7, $Cats/Cat8]]

func _ready():
	for cat in $Cats.get_children():
		cat.set_cat(cat.name.right(1))
	$Cats/Cat1.select("p1")
	
	$Players/CatP1.set_cat("1")
	$Players/CatP1.select("p1_no_label")
	$Players/CatP2.set_cat("random")
	$Players/CatP2.ready_up()
	if g.player_input_devices['p1'] == 'keyboard':
		$Players/CatP2/JoinJoypad.visible = true
		$Players/CatP2/JoinJoypad/Start.play()
	else:
		$Players/CatP2/JoinBoth.visible = true
		$Players/CatP2/JoinBoth/Both.play()

func _input(event):
	# p2 join
	var p2_joined = false
	if g.p2_cat == "cpu":
		if g.player_input_devices['p1'] != "keyboard" \
		and event is InputEvent and event.is_action_pressed("keyboard_submit"):
			g.player_input_devices['p2'] = 'keyboard'
			p2_joined = true
		elif g.player_input_devices['p1'] == "keyboard" \
		and event is InputEventJoypadButton and event.is_action_pressed("joypad_submit"):
			var device_name: String = Input.get_joy_name(event.device)
			if g.ghost_inputs.has(device_name):
				return
			g.player_input_devices['p2'] = 'joypad_' + str(event.device)
			p2_joined = true
	if p2_joined:
		g.p2_cat = '4'
		$Players/CatP2.set_cat('4')
		$Players/CatP2.unready()
		$Players/CatP2.select('p2_no_label')
		$Players/CatP2/JoinBoth.visible = false
		$Players/CatP2/JoinKeyboard.visible = false
		$Players/CatP2/JoinJoypad.visible = false
		$Players/P2.text = "P2"
		$Players/P2.modulate = Color("#D4715D")
		$Cats/Cat4.select('p2')
		ready_state['p2'] = false
		return
	# focus change
	var players: Array = ['p1']
	if g.p2_cat != 'cpu':
		players.append('p2')
	for p in players:
		if event is InputEvent and g.player_input_devices[p] == 'keyboard':
			if event.is_action_pressed('keyboard_up'):
				focus_prev_row(p)
			elif event.is_action_pressed('keyboard_down'):
				focus_next_row(p)
			elif event.is_action_pressed('keyboard_left'):
				focus_prev_column(p)
			elif event.is_action_pressed('keyboard_right'):
				focus_next_column(p)
			elif event.is_action_pressed("keyboard_select") \
			or event.is_action_pressed("keyboard_submit"):
				press_focused(p)
		elif event is InputEventJoypadButton \
		and g.player_input_devices[p] == 'joypad_' + str(event.device) \
		and !g.ghost_inputs.has(Input.get_joy_name(event.device)):
			if event.is_action_pressed('joypad_up'):
				focus_prev_row(p)
			elif event.is_action_pressed('joypad_down'):
				focus_next_row(p)
			elif event.is_action_pressed('joypad_left'):
				focus_prev_column(p)
			elif event.is_action_pressed('joypad_right'):
				focus_next_column(p)
			elif event.is_action_pressed("joypad_select") \
			or event.is_action_pressed("joypad_submit"):
				press_focused(p)

func focus_prev_row(player: String = 'p1'):
	focus[player].x -= 1
	if focus[player].x < 0:
		focus[player].x = cats.size() - 1
	focus_changed()

func focus_next_row(player: String = 'p1'):
	focus[player].x += 1
	if focus[player].x > cats.size() - 1:
		focus[player].x = 0
	focus_changed()

func focus_prev_column(player: String = 'p1'):
	focus[player].y -= 1
	if focus[player].y < 0:
		focus[player].y = cats[focus[player].x].size() - 1
	focus_changed()

func focus_next_column(player: String = 'p1'):
	focus[player].y += 1
	if focus[player].y > cats[focus[player].x].size() - 1:
		focus[player].y = 0
	focus_changed()

func focus_changed():
	for cat in $Cats.get_children():
		cat.select('none')
	if g.p2_cat == 'cpu':
		cats[focus['p1'].x][focus['p1'].y].select('p1')
	elif focus['p1'] == focus['p2']:
		cats[focus['p1'].x][focus['p1'].y].select('both')
	else:
		cats[focus['p1'].x][focus['p1'].y].select('p1')
		cats[focus['p2'].x][focus['p2'].y].select('p2')

func press_focused(p):
	# ready
	var cat_num = cats[focus[p].x][focus[p].y].name.right(1)
	if p == "p1":
		if g.p2_cat == cat_num:
			$MenuNo.play()
			return
		g.p1_cat = cat_num
		$Players/CatP1.set_cat(cat_num)
		$Players/CatP1.ready_up()
	else:
		if g.p1_cat == cat_num:
			$MenuNo.play()
			return
		g.p2_cat = cat_num
		$Players/CatP1.set_cat(cat_num)
		$Players/CatP2.ready_up()
	ready_state[p] = true
	# locked in
	for cat in $Cats.get_children():
		cat.unlock()		
		if ready_state['p1'] and cat.name.right(1) == g.p1_cat:
			cat.lock_in('p1')
		elif ready_state['p2'] and cat.name.right(1) == g.p2_cat:
			cat.lock_in('p2')
	$MenuYes.play()
	if ready_state['p1'] and ready_state['p2']:
		$StartGameTimer.start()

func _on_start_game_timer_timeout():
	if ready_state['p1'] and ready_state['p2']:
		get_tree().change_scene_to_file('res://scenes/game.tscn')
