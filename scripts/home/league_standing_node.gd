class_name LeagueStandingNode
extends Control

var entry_scene = preload("res://scenes/component/standings_entry.tscn")

@export var event_temp_label: Label
@export var event_header_container: HBoxContainer
@export var names_container: VBoxContainer
@export var player_label: Label
@export var results_container: VBoxContainer
@export var animation_player: AnimationPlayer

func setup(year: int, abbr: String = "JPDG") -> void:
	var league = Leagues.leagues[abbr]
	var events_dict = league["seasons"][str(year)]["events"]
	for event_type in ["MONTHLY_FLEX", "TWO_ROUND", "BAG_TAG", "MISC"]:
		if event_type in events_dict:
			for event in events_dict[event_type]:
				var node: Label = event_temp_label.duplicate()
				if "name" in event:
					node.text = event["name"]
				else:
					node.text = event["course"].split(" (")[0]
				node.add_theme_color_override("font_color", Common.EVENT_COLORS[event_type])
				node.visible = true
				event_header_container.add_child(node)
	_setup_players(league, events_dict, year)

func _setup_players(league: Dictionary, events_dict: Dictionary, year: int) -> void:
	var players: Array = []
	var events_map: Dictionary = {}
	if year == Time.get_datetime_dict_from_system()["year"]:
		players = league["admins"] + league["players"]
	for event_type in events_dict:
		events_map[event_type] = []
		for event in events_dict[event_type]:
			events_map[event_type].append(-1)
			for player in event["finish"]:
				if player not in players:
					players.append(player)
	var player_pts = {}
	for player in players:
		player_pts[player] = events_map.duplicate(true)
	for event_type in events_dict:
		for index in len(events_dict[event_type]):
			for player in player_pts:
				if player in events_dict[event_type][index]["finish"]:
					player_pts[player][event_type][index] = events_dict[event_type][index]["finish"][player]["points"]
	var entry_nodes = []
	for player in player_pts:
		var entry_node: StandingsEntryNode = entry_scene.instantiate()
		if "legacy_points" in league["seasons"][str(year)]:
			entry_node.setup(player_pts[player], player, league["seasons"][str(year)]["legacy_points"][player])
		else:
			entry_node.setup(player_pts[player], player)
		entry_nodes.append(entry_node)
	entry_nodes.sort_custom(func(a, b): return a.total_points > b.total_points)
	for node in entry_nodes:
		var name_label = player_label.duplicate()
		name_label.add_theme_color_override("font_color", Common.WHITE)
		var podium = ""
		if node.username in league["seasons"][str(year)]["podium"]:
			var place = league["seasons"][str(year)]["podium"][node.username]
			podium = " 🏆" if place == "1" else (" 🥈" if "2" in place else " 🥉")
			if place == "1":
				name_label.add_theme_color_override("font_color", Common.YELLOW)
		name_label.text = node.username.split(" ")[0] + podium
		names_container.add_child(name_label)
		results_container.add_child(node)
