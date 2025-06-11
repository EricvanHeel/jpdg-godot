class_name EventEntryNode
extends PanelContainer

var player_entry_scene = preload("res://scenes/league/player_event_entry.tscn")

const FLEX_POINTS = [20, 16, 13, 10, 7, 5, 3, 1]
const MAJOR_POINTS = [25, 19, 15, 12, 9, 7, 5, 3, 1]
const BAG_TAG_POINTS = [13, 10, 8, 6, 4, 3, 2, 1]

@export var title_label: Label
@export var courses_label: Label
@export var status_label: Label
@export var scores_container: VBoxContainer
@export var button: Button
@export var animation_player: AnimationPlayer
@export var complete_event_button: Button
@export var no_scores_label: Label

var type: String
var index: int
var year: String
var event: Dictionary

func setup(_type: String, _index: int, _year: String, league: String = "JPDG") -> void:
	type = _type
	index = _index
	year = _year
	event = Leagues.leagues[league]["seasons"][year]["events"][type][index]
	button.pressed.connect(_play_animation)
	complete_event_button.pressed.connect(_complete_event)
	_set_event_details()
	if not event["rounds"]:
		no_scores_label.visible = true
		complete_event_button.visible = false
	else:
		var player_node: PlayerEventEntryNode = player_entry_scene.instantiate()
		player_node.setup("PLAYER", "SCORE", "PLACE", "POINTS")
		scores_container.add_child(player_node)
		_set_event_positions()

func _complete_event() -> void:
	var finish = {}
	for node in scores_container.get_children():
		if node is PlayerEventEntryNode and node.name_label.text != "PLAYER":
			var place = node.place_edit.text if node.place_edit.text else node.place_edit.placeholder_text
			var points = node.points_edit.text if node.points_edit.text else node.points_edit.placeholder_text
			var strokes = node.score_label.text
			points = points.replace(Common.PERIOD, ".")
			finish[node.name_label.text] = {"place": place, "points": float(points), "strokes": int(strokes)}
	await Leagues.load_jpdg_from_remote()
	Leagues.add_finish_to_event(type, index, year, finish)
	get_tree().change_scene_to_file("res://scenes/home/home.tscn")

func _set_event_details() -> void:
	var today = Time.get_datetime_dict_from_system()
	match type:
		"MONTHLY_FLEX":
			title_label.text = Common.MONTH[int(event["month"])] + " Flex"
			courses_label.text = event["course"]
			if event["month"] > today["month"]:
				status_label.text = Common.MONTH[int(event["month"])]
			elif event["month"] == today["month"]:
				status_label.text = "In Progress"
				status_label.add_theme_color_override("font_color", Common.BRIGHT_GREEN)
				complete_event_button.visible = true
			else:
				status_label.text = "Event Over"
				status_label.add_theme_color_override("font_color", Common.BRIGHT_GREEN)
				complete_event_button.visible = true
		"TWO_ROUND":
			title_label.text = event["name"]
			courses_label.text = ", ".join(event["courses"])
			var event_date = Time.get_datetime_dict_from_datetime_string(event["date"], false)
			if event_date["month"] > today["month"] \
				or (event_date["month"] == today["month"] and event_date["day"] > today["day"]):
				status_label.text = Common.MONTH[int(event_date["month"])] + " " + str(event_date["day"])
			elif event_date["month"] == today["month"] and event_date["day"] == today["day"]:
				status_label.text == "In Progress"
				status_label.add_theme_color_override("font_color", Common.BRIGHT_GREEN)
				complete_event_button.visible = true
			else:
				status_label.text = "Event Over"
				status_label.add_theme_color_override("font_color", Common.BRIGHT_GREEN)
				complete_event_button.visible = true
		_:
			Common.log("Invalid event type: %s" % type, "ERROR")
	if event["finish"]:
		status_label.text = "Completed"
		complete_event_button.visible = false
		status_label.add_theme_color_override("font_color", Common.WHITE)

func _set_event_positions() -> void:
	if event["finish"]:
		var finishes = []
		for player in event["finish"]:
			finishes.append({
				"player": player,
				"place": event["finish"][player]["place"],
				"points": event["finish"][player]["points"],
				"strokes": event["finish"][player]["strokes"]
			})
		finishes.sort_custom(func(a, b): return a["points"] > b["points"])
		for finish in finishes:
			var player_entry_node: PlayerEventEntryNode = player_entry_scene.instantiate()
			player_entry_node.setup(finish["player"], str(finish["strokes"]), finish["place"], str(finish["points"]))
			scores_container.add_child(player_entry_node)
	else:
		_set_current_event_positions()

func _set_current_event_positions() -> void:
	var top_rounds = []
	var points = []
	match type:
		"MONTHLY_FLEX":
			points = FLEX_POINTS
			for player in event["rounds"]:
				var top_round = 999
				for round_id in event["rounds"][player]:
					var round = Rounds.get_round_by_uuid(player, event["course"], year, round_id)
					var strokes = round["scores"].reduce(func(a, x): return a + x["strokes"], 0)
					if strokes < top_round:
						top_round = strokes
				top_rounds.append({"player": player, "strokes": top_round})
		"TWO_ROUND":
			points = MAJOR_POINTS
	top_rounds.sort_custom(func(a, b): return a["strokes"] < b["strokes"])
	var total_points
	var points_index = 0
	var i = 0
	while i < len(top_rounds):
		var top_place = i + 1
		total_points = 0 if points_index >= len(points) else points[points_index]
		var check_next_player = (i + 1) < len(top_rounds)  # init this bool to "is this not the last player"
		var tied_players = [top_rounds[i]]
		while check_next_player:
			if top_rounds[i + 1]["strokes"] == top_rounds[i]["strokes"]:
				points_index += 1
				if points_index < len(points):
					total_points += points[points_index]
				tied_players.append(top_rounds[i + 1])
				i += 1
				check_next_player = (i + 1) < len(top_rounds)
			else:
				break
		var pts = snapped(float(total_points) / len(tied_players), 0.1)
		for entry in tied_players:
			entry["pts"] = pts
			if len(tied_players) == 1:
				entry["place"] = str(top_place)
			else:
				entry["place"] = "T" + str(top_place)
		points_index += 1
		i += 1
	for entry in top_rounds:
		var player_entry_node: PlayerEventEntryNode = player_entry_scene.instantiate()
		player_entry_node.setup(entry["player"], str(entry["strokes"]), entry["place"], str(entry["pts"]))
		scores_container.add_child(player_entry_node)

func _play_animation() -> void:
	if scores_container.visible:
		animation_player.play("collapse")
	else:
		animation_player.play("expand")




















# EOF
