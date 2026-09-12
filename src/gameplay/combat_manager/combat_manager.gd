extends Node3D

signal combat_start
signal combat_end

var turn_manager

func start_combat():
	combat_start.emit()
	turn_manager.initialize()

func _play_turn():
	var players = get_tree().get_nodes_in_group("player")
	var mobs = get_tree().get_nodes_in_group("mob_npc")
	

func _end_combat():
	combat_end.emit()
