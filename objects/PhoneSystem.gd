extends Node

const NEW_MESSAGE_DELAY : float = 25.0
const RESPONSE_TIME_LIMIT : float = 18.0
const WRONG_ANSWER_LIMIT : int = 3

enum MessageType {GREETING, RANDOM, DETAIL, REFLECTION_PROMPT, REFLECTION, REFLECTION_WIN}

onready var timer_ghost_timer = $Timer_GhostTimer
onready var timer_new_message = $Timer_NewMessage
onready var timer_warning = $Timer_Warning
onready var audio_vibrate = $Audio_Vibrate
onready var audio_correct_answer = $Audio_CorrectAnswer
onready var audio_wrong_answer = $Audio_WrongAnswer
onready var audio_warning = $Audio_Warning

var messages : Array # The deck of messages
var message_index_of_type : Dictionary = {
	MessageType.GREETING: [],
	MessageType.RANDOM: [],
	MessageType.DETAIL: [],
	MessageType.REFLECTION_PROMPT: [],
	MessageType.REFLECTION: [],
	MessageType.REFLECTION_WIN: []
}

# This could be randomised slightly to be a bit more organic, but it's fine for now.
const message_order : Array = [
	MessageType.GREETING,
	MessageType.RANDOM,
	MessageType.DETAIL,
	MessageType.RANDOM,
	MessageType.REFLECTION_PROMPT,
	MessageType.REFLECTION,
	MessageType.REFLECTION_WIN
]

var message_index : int = -1 # What type of message are we currently asking?
var current_message : int = 0 # Which message in the deck?
var message_counter : Dictionary = {
	MessageType.GREETING: 0,
	MessageType.RANDOM: 0,
	MessageType.DETAIL: 0,
	MessageType.REFLECTION_PROMPT: 0,
	MessageType.REFLECTION_WIN: 0
}

var last_detail_index : int = -1
var message_awaiting_response : bool = false

var wrong_answers : int = 0

signal new_message_received
signal response_timeout
signal too_many_wrong_answers

func get_message_body(index : int) -> String:
	return messages[index]["line"]

func get_message_responses(index : int) -> Array:
	return messages[index]["answers"]

func get_message_correct_response(index : int) -> int:
	return messages[index]["correct_answer"]

func get_reflection_message_with_detail_index(detail_index : int) -> int:
	for message_index in message_index_of_type[MessageType.REFLECTION]:
		var message : Dictionary = messages[message_index]
		if message["detail_index"] == detail_index:
			return message_index
	# Couldn't find reflection message! PANIK!
	printerr("Could not find reflection message with detail index ", detail_index)
	return -1

func choose_message_of_type(type : int) -> int:
	if type == MessageType.REFLECTION:
		return get_reflection_message_with_detail_index(last_detail_index)
	if message_counter.has(type):
		var counter : int = message_counter[type] % message_index_of_type[type].size()
		var result : int = message_index_of_type[type][counter]
		message_counter[type] += 1
		return result
	# Don't know how to handle this message type
	printerr("Couldn't choose a message with type ", type)
	return -1

func get_next_message_index() -> int:
	message_index += 1
	if message_index >= message_order.size():
		message_index = 1 # Skip the greeting when repeating
	# What type of message is up next?
	var type : int = message_order[message_index]
	var index : int = choose_message_of_type(type)
	return index

func next_message() -> void:
	var index : int = get_next_message_index()
	var message : Dictionary = messages[index]
	if message["type"] == "detail":
		last_detail_index = message["detail_index"]
	current_message = index
	emit_signal("new_message_received", index)

func evaluate_response(response_index : int) -> void:
	if response_index == get_message_correct_response(current_message):
		audio_correct_answer.play()
	else:
		audio_wrong_answer.play()
		wrong_answers += 1
		if wrong_answers >= WRONG_ANSWER_LIMIT:
			emit_signal("too_many_wrong_answers")
	# Set up for the next message
	message_awaiting_response = false
	timer_ghost_timer.stop()
	timer_new_message.start(NEW_MESSAGE_DELAY)
	timer_warning.stop()
	audio_warning.stop()

func start_system() -> void:
	message_awaiting_response = false
	timer_new_message.start(NEW_MESSAGE_DELAY)

# When this passes, the player has gone too long without responding! Game over!
func _on_Timer_GhostTimer_timeout() -> void:
	emit_signal("response_timeout")

func _on_Timer_Warning_timeout() -> void:
	audio_warning.play()

func _on_Timer_NewMessage_timeout() -> void:
	message_awaiting_response = true
	timer_ghost_timer.start(RESPONSE_TIME_LIMIT)
	timer_warning.start(RESPONSE_TIME_LIMIT - 10.0)
	next_message()
	audio_vibrate.play()

func create_message_index() -> void:
	# Clear the indexes first
	for index in message_index_of_type.values():
		index.clear()
	# Sort 'em!
	for i in range(0, messages.size()):
		var message : Dictionary = messages[i]
		match message["type"]:
			"greeting":
				message_index_of_type[MessageType.GREETING].append(i)
			"random":
				message_index_of_type[MessageType.RANDOM].append(i)
			"detail":
				message_index_of_type[MessageType.DETAIL].append(i)
			"reflection_prompt":
				message_index_of_type[MessageType.REFLECTION_PROMPT].append(i)
			"reflection":
				message_index_of_type[MessageType.REFLECTION].append(i)
			"reflection_win":
				message_index_of_type[MessageType.REFLECTION_WIN].append(i)
	# Now shuffle 'em
	randomize()
	for index in message_index_of_type.values():
		index.shuffle()

func load_messages() -> void:
	var f : File = File.new()
	f.open("res://data/partner_convo.json", File.READ)
	var contents : String = f.get_as_text()
	var json = parse_json(contents)
	messages = json["questions"]

func test_messages() -> void:
	for i in range(0, 50):
		var index : int = get_next_message_index()
		var message : Dictionary = messages[index]
		if message["type"] == "detail":
			last_detail_index = message["detail_index"]
		var message_body : String = message["line"]
		print(message_body)

func _enter_tree() -> void:
	load_messages()
	create_message_index()
