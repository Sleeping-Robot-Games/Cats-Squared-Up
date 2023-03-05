extends Control

var cat: String = '1'
var is_locked: bool = false

func set_cat(new_cat: String):
	cat = new_cat
	if new_cat == 'random':
		$Cat.texture = load('res://assets/random.png')
	else:
		$Cat.texture = load('res://assets/faces/'+new_cat+'.png')

func select(state: String):
	$None.visible = false
	$P1.visible = false
	$P1NoLabel.visible = false
	$P2.visible = false
	$P2NoLabel.visible = false
	$Both.visible = false
	if state == 'none':
		$None.visible = true
	elif state == 'p1':
		$P1.visible = true
	elif state == 'p1_no_label':
		$P1NoLabel.visible = true
	elif state == 'p2':
		$P2.visible = true
	elif state == 'p2_no_label':
		$P2NoLabel.visible = true
	elif state == 'both':
		$Both.visible = true

func choose(player: String):
	if player == 'p1':
		$P1Chosen.visible = true
	else:
		$P2Chosen.visible = true

func unchoose():
	$P1Chosen.visible = false
	$P2Chosen.visible = false

func lock():
	is_locked = true
	$Locked.visible = true

func unlock():
	is_locked = false
	$Locked.visible = false

func ready_up():
	$Ready.visible = true

func unready():
	$Ready.visible = false
