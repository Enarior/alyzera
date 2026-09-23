extends Node3D

signal combat_start
signal combat_end

var in_combat
var players
var mobs

func start_combat():
	if in_combat: return
	in_combat = true
	%TurnManager.initialize()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	players = get_tree().get_nodes_in_group("player")
	mobs = get_tree().get_nodes_in_group("mob_npc")
	
	_emit_combat_start.rpc()
	
#
#func _play_turn():
	#var players = get_tree().get_nodes_in_group("player")
	#var mobs = get_tree().get_nodes_in_group("mob_npc")

@rpc("authority", "call_local", "reliable")
func _emit_combat_start():
	#Global.("combat started rpc called")
	combat_start.emit()

	

func _end_combat():
	in_combat = false
	combat_end.emit()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func end_turn():
	%TurnManager.active_character.end_turn.emit()
	%TurnManager.play_turn()

func attack(target):
	Global.print_with_id(%TurnManager.active_character + " attacks " + target)
