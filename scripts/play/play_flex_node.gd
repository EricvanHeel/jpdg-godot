class_name PlayFlexNode
extends Control

@export var header_node: HeaderNode

@export var available_players: VBoxContainer
@export var card_players: VBoxContainer
@export var dummy_player_button: Button

@export var course_label: Label
@export var par_rating: Label
@export var jpdg_avg: Label
@export var user_avg: Label

func _ready() -> void:
	var event = Leagues.get_current_flex()
	if not event:
		Common.log("No flex event found this month", "ERROR")
	header_node.setup("cancel_button", "play_button", Common.MONTH[int(event["month"])] + " Flex")
	header_node.left_pressed.connect(_change_scene.bind("res://scenes/home/home.tscn"))
	header_node.right_pressed.connect(_play_round)
	for player in Leagues.members():
		if player not in event["rounds"] or len(event["rounds"][player]) < 2:
			_add_player_button(player)
	course_label.text = event["course"]
	var course = Courses.courses[event["course"]]
	par_rating.text = str(course["rating"])
	jpdg_avg.text = Courses.get_course_average(event["course"])
	user_avg.text = Courses.get_course_average(event["course"], [ClientData.user])

func _add_player_button(player: String) -> void:
	var button = dummy_player_button.duplicate()
	button.visible = true
	button.text = player
	button.pressed.connect(_player_selected.bind(button))
	if player == ClientData.user:
		card_players.add_child(button)
		return
	available_players.add_child(button)

func _player_selected(button: Button) -> void:
	if button in card_players.get_children():
		card_players.remove_child(button)
		available_players.add_child(button)
	else:
		available_players.remove_child(button)
		card_players.add_child(button)
	header_node.right_button.disabled = card_players.get_child_count() == 0

func _play_round() -> void:
	ClientData.play_round_course = course_label.text
	ClientData.play_round_event_title = header_node.title_label.text
	for player_button in card_players.get_children():
		ClientData.play_round_card.append(player_button.text)
	_change_scene("res://scenes/play/play.tscn")

func _change_scene(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)
