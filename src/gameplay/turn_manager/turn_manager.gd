extends Node3D

var active_character
var turn_playing = false
var units: Array[CharacterBody3D] = []

func _ready():
	CombatManager.turn_manager = self
	
func initialize():
	print("initialize turn order")
	if units.size()>0:
		active_character = units[0]
		print(units.size(), " units")
	else:
		push_error("Can not initialize TurnManager : queue empty")
	
	units.sort_custom(sort_units)
	print("units : ", units)
	

func sort_units(a , b):
	# TODO need type check or type hinting
	print("a : ", a.initiative, " b : ", b.initiative )
	return a.initiative > b.initiative


func play_turn():
	turn_playing = true
	print(active_character.name + " turn at index ", units.find(active_character), "...")
	await active_character.play_turn();"completed"
	var next_index = (units.find(active_character) + 1) % units.size() # Only first occurence, change that later
	active_character = units[next_index]
	turn_playing = false
	

func add_unit(unit: CharacterBody3D):
	if unit != null:
		units.append(unit)
	else :
		push_error("Can't add null unit to turn order")
		
