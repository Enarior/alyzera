@abstract
extends Npc
class_name MobNpc

@export var initiative: int = 5

@abstract func play_turn()

func _ready():
	add_to_group("mob_npc")
