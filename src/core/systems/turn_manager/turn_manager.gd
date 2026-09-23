extends Node3D

var active_character
var turn_playing = false
var units: Array[CharacterBody3D] = []

@onready var combat_hud = $"../../HUDLayer/HUDRoot/CombatHUD"

func initialize():
	if not multiplayer.is_server() : return
	Global.print_with_id("initialize turn order")
	
	units.sort_custom(sort_units)
	
	if units.size()>0:
		active_character = units[0]
		Global.print_with_id(str(units.size()) + " units")
	else:
		push_error("Can not initialize TurnManager : queue empty")
	
	Global.print_with_id("units : " + str(units))
	play_turn()


func sort_units(a , b):
	# TODO need type check or type hinting
	return a.initiative > b.initiative


func play_turn():
	if not multiplayer.is_server() : return
	
	turn_playing = true
	Global.print_with_id(active_character.name + " turn at index " + str(units.find(active_character)) + "...")
	
	combat_hud.set_current_character(active_character)
	if multiplayer.is_server() and active_character is Player:
		combat_hud.toggle_turn_hud.rpc_id(int(active_character.name))	
	active_character.play_turn()
	await active_character.end_turn
	if multiplayer.is_server() and active_character is Player:
		combat_hud.toggle_turn_hud.rpc_id(int(active_character.name))
	
	var next_index = (units.find(active_character) + 1) % units.size() # Only first occurence, change that later
	active_character = units[next_index]
	
	turn_playing = false
	

#@rpc("any_peer", "call_local", "reliable")
func add_unit(unit: CharacterBody3D):
	if not multiplayer.is_server(): return
	Global.print_with_id("add unit : " + str(unit))
	if unit != null:
		units.append(unit)
	else :
		push_error("Can't add null unit to turn order")
		
