extends Node3D

var in_combat
var players
var mobs

signal combat_start
signal combat_end

func start_combat():
	if in_combat: return
	combat_start.emit()
	in_combat = true
	%TurnManager.initialize()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	players = get_tree().get_nodes_in_group("player")
	mobs = get_tree().get_nodes_in_group("mob_npc")
	
	Global.print_with_id("combat manager combat start")
	for player in players:
		player.start_combat.rpc()

#
#func _play_turn():
	#var players = get_tree().get_nodes_in_group("player")
	#var mobs = get_tree().get_nodes_in_group("mob_npc")

	

func _end_combat():
	in_combat = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func end_turn():
	%TurnManager.active_character.end_turn.emit()
	%TurnManager.play_turn()

func attack(target):
	Global.print_with_id(%TurnManager.active_character + " attacks " + target)
