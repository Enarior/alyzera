extends Node

#signal change_level

#signal init_player

var instance_type

func print_with_id(message: String):
	if OS.has_feature("server"):
		instance_type = "server"
	else:
		instance_type = "client"
	print(instance_type + " : "  + message)
