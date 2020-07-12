extends Control

onready var label_message = $Bubble/Label_Message

var which_response : int

signal response_selected

func set_message_body(body : String) -> void:
	label_message.text = body

func _selected() -> void:
	emit_signal("response_selected", which_response)
