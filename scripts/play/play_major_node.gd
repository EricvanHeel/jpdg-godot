class_name PlayMajorNode
extends PanelContainer

@export var header_node: HeaderNode
@export var courses_label: Label
@export var course_button_1: Button
@export var course_button_2: Button
@export var rating_label: Label
@export var jpdg_avg_label: Label
@export var user_avg_label: Label
@export var available_players: VBoxContainer
@export var card_players: VBoxContainer
@export var dummy_player_button: Button

var selected_course: String = ""

func _ready() -> void:
	var event = Leagues.get_current_two_round()
	if not event:
		Common.log("No major event found this month", "ERROR")
	header_node.setup("home_button", "play_button", event["name"])
	header_node.left_pressed.connect(_change_scene.bind("res://scenes/home/home.tscn"))
	header_node.right_pressed.connect(_play_round)
	var courses = []
	for course in event["courses"]:
		courses.append(course.split(" (")[0])
	courses_label.text = " & ".join(courses)
	for player in Leagues.members():
		if player not in event["rounds"] or len(event["rounds"][player]) < 2:
			_add_player_button(player)
	if len(courses) > 1:
		header_node.right_button.disabled = true
		course_button_1.text = courses[0]
		course_button_1.pressed.connect(_course_selected.bind(event["courses"][0]))
		course_button_2.text = courses[1]
		course_button_2.pressed.connect(_course_selected.bind(event["courses"][1]))
	else:
		course_button_1.visible = false
		course_button_2.visible = false
		_course_selected(event["courses"][0])

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
	header_node.right_button.disabled = card_players.get_child_count() == 0 or not selected_course

func _course_selected(course: String) -> void:
	selected_course = course
	rating_label.text = str(Courses.courses[course]["rating"])
	jpdg_avg_label.text = Courses.get_course_average(course)
	user_avg_label.text = Courses.get_course_average(course, [ClientData.user])
	header_node.right_button.disabled = card_players.get_child_count() == 0 or not selected_course

func _play_round() -> void:
	ClientData.play_round_course = selected_course
	ClientData.play_round_event_title = header_node.title_label.text
	for player_button in card_players.get_children():
		ClientData.play_round_card.append(player_button.text)
	_change_scene("res://scenes/play/play.tscn")

func _change_scene(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)
