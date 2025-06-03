class_name LeagueStandingNode
extends Control

var entry_scene = preload("res://scenes/component/standings_entry.tscn")

@export var flex_1_label: Label
@export var flex_2_label: Label
@export var flex_3_label: Label
@export var flex_4_label: Label
@export var flex_5_label: Label
@export var flex_6_label: Label
@export var major_1_label: Label
@export var major_2_label: Label
@export var major_3_label: Label
@export var major_4_label: Label

@export var names_container: VBoxContainer
@export var player_label: Label
@export var results_container: VBoxContainer

var players: Dictionary = {}

func setup(year: int, abbr: String = "JPDG") -> void:
	var league = Leagues.leagues[abbr]
	var events_dict = league["seasons"][str(year)]["events"]
	flex_1_label.text = events_dict["MONTHLY_FLEX"][0]["course"]
	flex_2_label.text = events_dict["MONTHLY_FLEX"][1]["course"]
	flex_3_label.text = events_dict["MONTHLY_FLEX"][2]["course"]
	flex_4_label.text = events_dict["MONTHLY_FLEX"][3]["course"]
	flex_5_label.text = events_dict["MONTHLY_FLEX"][4]["course"]
	flex_6_label.text = events_dict["MONTHLY_FLEX"][5]["course"]
	major_1_label.text = events_dict["TWO_ROUND"][0]["name"]
	major_2_label.text = events_dict["TWO_ROUND"][1]["name"]
	major_3_label.text = events_dict["TWO_ROUND"][2]["name"]
	major_4_label.text = events_dict["TWO_ROUND"][3]["name"]
	
	var entry_nodes = []
	for player in league["admins"] + league["players"]:
		var pts = []
		for event in events_dict["MONTHLY_FLEX"]:
			if player in event["finish"]:
				pts.append(event["finish"][player]["points"])
			else:
				pts.append(-1)
		for event in events_dict["TWO_ROUND"]:
			if player in event["finish"]:
				pts.append(event["finish"][player]["points"])
			else:
				pts.append(-1)
		var entry_node: StandingsEntryNode = entry_scene.instantiate()
		entry_node.setup(pts, player)
		entry_nodes.append(entry_node)
	entry_nodes.sort_custom(func(a, b): return a.total_points > b.total_points)
	for node in entry_nodes:
		var name_label = player_label.duplicate()
		name_label.text = node.username.split(" ")[0]
		name_label.add_theme_color_override("font_color", Common.WHITE)
		names_container.add_child(name_label)
		results_container.add_child(node)
