## Headless smoke test for the live matchmaking client, driven from the command line:
##   godot --headless --path . tools/test_live_client.tscn
## Needs a real opponent queued on the same category (see quizz-backend/tools/test_live_opponent.py)
## and the local backend running (docker compose up in ~/Documents/quizz-backend).
extends Node

var _answer_choice: int = 0


func _ready() -> void:
	NetworkManager.player_ready.connect(_on_player_ready)
	NetworkManager.live_match_found.connect(_on_match_found)
	NetworkManager.live_question.connect(_on_question)
	NetworkManager.live_reveal.connect(_on_reveal)
	NetworkManager.live_match_over.connect(_on_match_over)
	NetworkManager.live_error.connect(_on_error)

	var timeout := Timer.new()
	timeout.wait_time = 30.0
	timeout.one_shot = true
	timeout.timeout.connect(func():
		print("[test_live_client] TIMEOUT after 30s")
		get_tree().quit(1)
	)
	add_child(timeout)
	timeout.start()

	if not NetworkManager.player_id.is_empty():
		_on_player_ready(NetworkManager.player_id)


func _on_player_ready(player_id: String) -> void:
	print("[test_live_client] player_ready: %s" % player_id)
	NetworkManager.start_live_matchmaking("sport")


func _on_match_found(data: Dictionary) -> void:
	print("[test_live_client] match_found: %s" % data)


func _on_question(data: Dictionary) -> void:
	print("[test_live_client] question %d: %s" % [int(data.get("index", -1)), data.get("text", "")])
	NetworkManager.send_live_answer(int(data.get("index", 0)), _answer_choice)


func _on_reveal(data: Dictionary) -> void:
	print("[test_live_client] reveal: %s" % data)


func _on_match_over(data: Dictionary) -> void:
	print("[test_live_client] match_over: %s" % data)
	get_tree().quit(0)


func _on_error(reason: String) -> void:
	print("[test_live_client] ERROR: %s" % reason)
	get_tree().quit(1)
