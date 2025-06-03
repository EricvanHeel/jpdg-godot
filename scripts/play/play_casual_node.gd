class_name PlayCasualNode
extends Control

@export var header_node: HeaderNode
@export var course_select: OptionButton
@export var select_course_message: Label

@export var available_players: VBoxContainer
@export var card_players: VBoxContainer
@export var dummy_player_button: Button

@export var par_rating: Label
@export var jpdg_avg: Label
@export var user_avg: Label

func _ready() -> void:
	header_node.setup("cancel_button", "play_button", "Play Round")
	header_node.left_pressed.connect(_change_scene.bind("res://scenes/home/home.tscn"))
	header_node.right_pressed.connect(_play_round)
	_enable_disable_play_button()
	for player in Common.PLAYERS:
		_add_player_button(player)
	for course_name in Courses.courses:
		course_select.add_item(course_name)
	course_select.selected = -1
	course_select.item_selected.connect(_select_course)

func _select_course(item_index: int) -> void:
	select_course_message.visible = false
	var course_name = course_select.get_item_text(item_index)
	par_rating.text = str(Courses.courses[course_name]["rating"])
	jpdg_avg.text = Courses.get_course_average(course_name)
	user_avg.text = Courses.get_course_average(course_name, [ClientData.user])
	_enable_disable_play_button()

func _enable_disable_play_button() -> void:
	var disabled = card_players.get_child_count() == 0 or course_select.selected == -1
	header_node.right_button.disabled = disabled

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
	_enable_disable_play_button()

func _play_round() -> void:
	ClientData.play_round_course = course_select.get_item_text(course_select.selected)
	ClientData.play_round_event_title = "Joe Pesci"
	for player_button in card_players.get_children():
		ClientData.play_round_card.append(player_button.text)
	_change_scene("res://scenes/play/play.tscn")

func _change_scene(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)
