extends Control

func _ready():
	%CombatManager.combat_start.connect(show)

func set_current_character(character: Node3D):
	$ActiveCharacterLabel.text = character.name

@rpc("authority", "call_local", "reliable", 0)
func toggle_turn_hud():
	if $TurnHud.visible : 
		$TurnHud.hide()
	else:
		$TurnHud.show()


func _on_attack_button_pressed() -> void:
	%CombatManager.attack("golem")


func _on_end_turn_button_pressed() -> void:
	%CombatManager.end_turn()
