class_name PlayNode
extends Control

var score_scene = preload("res://scenes/play/score.tscn")
var scorecard_scene = preload("res://scenes/component/scorecard.tscn")

@export var cancel_button: Button
@export var prev_hole_button: Button
@export var next_hole_button: Button

@export var title: Label
@export var course_label: Label

@export var par_label: Label
@export var hole_label: Label
@export var distance_label: Label
@export var description_label: Label
@export var alt_left_button: Button
@export var alt_right_button: Button

@export var user_avg: Label
@export var jpdg_avg: Label
@export var difficulty: Label
@export var players_container: VBoxContainer

@export var score_container: VBoxContainer
@export var review_container: ScrollContainer
@export var scorecards_container: VBoxContainer
@export var hole_details_grid: GridContainer

@export var loading_animation: LoadingNode

var course: Dictionary
var current_hole_index: int = 0
var holes_and_alts: Array = []
var difficulties: Array = []

func _ready() -> void:
	course = Courses.courses[ClientData.play_round_course]
	title.text = ClientData.play_round_event_title
	course_label.text = course["name"]
	_init_holes_and_alts()
	_set_current_hole()
	for player in ClientData.play_round_card:
		var node: ScoreNode = score_scene.instantiate()
		node.setup(player, course)
		players_container.add_child(node)
	next_hole_button.pressed.connect(_next_hole)
	cancel_button.pressed.connect(_cancel_round)
	prev_hole_button.pressed.connect(_prev_hole)
	alt_left_button.pressed.connect(_change_alt.bind(false))
	alt_right_button.pressed.connect(_change_alt.bind(true))

func _next_hole() -> void:
	current_hole_index += 1
	if current_hole_index == len(holes_and_alts) + 1:
		_submit_rounds()
		return
	if current_hole_index == len(holes_and_alts):
		_display_scorecards()
		return
	_set_current_hole()
	for player: ScoreNode in players_container.get_children():
		player.next_hole()

func _prev_hole() -> void:
	current_hole_index -= 1
	if current_hole_index == len(holes_and_alts) - 1:
		score_container.visible = true
		description_label.visible = holes_and_alts[current_hole_index]["desc"] != ""
		hole_details_grid.visible = true
		review_container.visible = false
		return
	_set_current_hole()
	for player: ScoreNode in players_container.get_children():
		player.prev_hole()

func _display_scorecards() -> void:
	score_container.visible = false
	description_label.visible = false
	hole_details_grid.visible = false
	review_container.visible = true
	for child in scorecards_container.get_children():
		scorecards_container.remove_child(child)
		child.queue_free()
	for score_node: ScoreNode in players_container.get_children():
		var scorecard: ScorecardNode = scorecard_scene.instantiate()
		scorecard.setup(score_node.round)
		scorecards_container.add_child(scorecard)
		scorecard.expand_pressed()

func _submit_rounds() -> void:
	loading_animation.animation_player.play("loading")
	var rounds = []
	for score_node: ScoreNode in players_container.get_children():
		score_node.round["timestamp"] = int(Time.get_unix_time_from_system())
		rounds.append(score_node.round)
	await Request.post_rounds(rounds)
	await Rounds.load_latest_rounds_from_remote()
	await Courses.load_courses_from_remote()
	await Leagues.load_jpdg_from_remote()
	if " Flex" in ClientData.play_round_event_title:
		Leagues.add_rounds_to_current_flex(rounds)
	ClientData.update("", int(Time.get_unix_time_from_system()))
	ClientData.clear_play_round()
	get_tree().change_scene_to_file("res://scenes/home/home.tscn")

func _set_current_hole() -> void:
	cancel_button.visible = current_hole_index == 0
	prev_hole_button.visible = current_hole_index > 0
	var hole_dict = holes_and_alts[current_hole_index]
	par_label.text = str(hole_dict["par"])
	hole_label.text = hole_dict["hole"]
	distance_label.text = str(hole_dict["dist"]) + "ft"
	user_avg.text = _get_formatted_float(hole_dict["user_avg"])
	jpdg_avg.text = _get_formatted_float(hole_dict["jpdg_avg"])
	difficulty.text = str(difficulties.find(str(current_hole_index + 1)) + 1)
	description_label.text = hole_dict["desc"]
	description_label.visible = hole_dict["desc"] != ""
	alt_left_button.visible = len(hole_dict["alts"]) > 0
	alt_right_button.visible = len(hole_dict["alts"]) > 0

func _change_alt(right_button: bool) -> void:
	var new_hole: Dictionary
	var old_hole = {
		"hole": holes_and_alts[current_hole_index]["hole"],
		"par": holes_and_alts[current_hole_index]["par"],
		"dist": holes_and_alts[current_hole_index]["dist"],
		"desc": holes_and_alts[current_hole_index]["desc"],
		"user_avg": holes_and_alts[current_hole_index]["user_avg"],
		"jpdg_avg": holes_and_alts[current_hole_index]["jpdg_avg"]
	}
	if right_button:
		new_hole = holes_and_alts[current_hole_index]["alts"].pop_front()
		holes_and_alts[current_hole_index]["alts"].append(old_hole)
	else:
		new_hole = holes_and_alts[current_hole_index]["alts"].pop_back()
		holes_and_alts[current_hole_index]["alts"].insert(0, old_hole)
	holes_and_alts[current_hole_index]["hole"] = new_hole["hole"]
	holes_and_alts[current_hole_index]["par"] = new_hole["par"]
	holes_and_alts[current_hole_index]["dist"] = new_hole["dist"]
	holes_and_alts[current_hole_index]["desc"] = new_hole["desc"]
	holes_and_alts[current_hole_index]["user_avg"] = new_hole["user_avg"]
	holes_and_alts[current_hole_index]["jpdg_avg"] = new_hole["jpdg_avg"]
	_set_current_hole()
	for score: ScoreNode in players_container.get_children():
		score.set_alt(holes_and_alts[current_hole_index]["hole"], holes_and_alts[current_hole_index]["par"])

func _init_holes_and_alts() -> void:
	var temp_difficulties: Array = []
	for i in range(len(course["holes"])):
		var hole_name = str(i + 1)
		var hole = course["holes"][hole_name]
		var hole_dict = {
			"hole": hole_name,
			"par": hole["par"],
			"dist": str(hole["dist"]),
			"desc": hole["desc"],
			"user_avg": Rounds.get_hole_average(course["name"], hole_name, [ClientData.user]),
			"jpdg_avg": Rounds.get_hole_average(course["name"], hole_name),
			"alts": []
		}
		temp_difficulties.append({"hole": hole_name, "avg": hole_dict["jpdg_avg"] - hole["par"]})
		for alt: String in course["alternates"]:
			if alt.begins_with(hole_name + "-"):
				var alt_hole = course["alternates"][alt]
				hole_dict["alts"].append({
					"hole": alt,
					"par": alt_hole["par"],
					"dist": str(alt_hole["dist"]),
					"desc": alt_hole["desc"],
					"user_avg": Rounds.get_hole_average(course["name"], alt, [ClientData.user]),
					"jpdg_avg": Rounds.get_hole_average(course["name"], alt)
				})
		holes_and_alts.append(hole_dict)
	temp_difficulties.sort_custom(func(a, b): return a["avg"] > b["avg"])
	for hole in temp_difficulties:
		difficulties.append(hole["hole"])

func _get_formatted_float(num: float) -> String:
	if num == 0:
		return "-"
	return ("%.1f" % num).replace(".", "․")

func _cancel_round() -> void:
	ClientData.play_round_card = []
	ClientData.play_round_course = ""
	ClientData.play_round_event_title = ""
	get_tree().change_scene_to_file("res://scenes/home/home.tscn")
