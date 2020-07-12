extends Control

onready var phone = $Phone
onready var label_message = $Phone/Label_Message
onready var response_box = $Responses
onready var tween = $Tween

onready var responses : Array = [
	$Responses/Response1,
	$Responses/Response2,
	$Responses/Response3
]

signal response_sent
signal back_from_phone

func appear() -> void:
	tween.stop_all()
	tween.interpolate_property(phone, "rect_position", phone.rect_position, Vector2(172, 20), 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.interpolate_property(response_box, "rect_position", response_box.rect_position, Vector2(4, 4), 1.0, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	tween.start()

func disappear() -> void:
	tween.stop_all()
	tween.interpolate_property(phone, "rect_position", phone.rect_position, Vector2(172, 210), 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN)
	tween.interpolate_property(response_box, "rect_position", response_box.rect_position, Vector2(4, -160), 0.5, Tween.TRANS_BACK, Tween.EASE_IN)
	tween.start()

func set_message_body(body : String) -> void:
	label_message.text = body

func set_responses(response_messages : Array) -> void:
	for i in range(0, responses.size()):
		responses[i].set_message_body(response_messages[i])

func response_selected(which : int) -> void:
	emit_signal("response_sent", which)
	disappear()
	yield(tween, "tween_all_completed")
	emit_signal("back_from_phone")

func _ready() -> void:
	for i in range(0, responses.size()):
		var response = responses[i]
		response.which_response = i
		response.connect("response_selected", self, "response_selected")
