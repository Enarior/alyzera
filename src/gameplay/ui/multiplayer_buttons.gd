extends Control

signal joined

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_client_button_pressed() -> void:
	joined.emit()
	
	HighLevelNetworkHandler.start_client()
	
	hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_server_button_pressed() -> void:
	joined.emit()
	HighLevelNetworkHandler.start_server()
		
	hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
