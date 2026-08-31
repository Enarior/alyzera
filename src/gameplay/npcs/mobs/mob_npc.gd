@abstract
extends Npc
class_name MobNpc

@abstract func play_turn()

func _ready():
	add_to_group("mob_npc")
