@abstract
class_name BaseLevel
extends Node3D
## Abstract class for levels

## Provides a player spawn location
@abstract func get_default_player_spawn() -> Vector3

var spawns : Array[Marker3D]


func get_npc_spawns() -> Array[Marker3D]:
	
	for spawn in %NpcSpawners.get_children():
		spawns.append(spawn)
	
	return spawns
