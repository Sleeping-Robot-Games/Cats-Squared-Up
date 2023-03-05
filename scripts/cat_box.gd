extends Control

var cat: String = '1'

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

func lock_in(player: String):
	if player == 'p1':
		$P1Locked.visible = true
	else:
		$P2Locked.visible = true

func unlock():
	$P1Locked.visible = false
	$P2Locked.visible = false

func ready_up():
	$Ready.visible = true

func unready():
	$Ready.visible = false
