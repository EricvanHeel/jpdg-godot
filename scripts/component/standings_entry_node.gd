class_name StandingsEntryNode
extends Control

@export var total_pts_label: Label
@export var event_pts_temp_label: Label
@export var results_container: HBoxContainer

var total_points: float = 0
var username: String

func setup(player_pts: Dictionary, user: String, legacy_pts: float = 0) -> void:
	username = user
	if "MONTHLY_FLEX" in player_pts:
		_setup_flex(player_pts["MONTHLY_FLEX"])
	if "TWO_ROUND" in player_pts:
		_setup_major(player_pts["TWO_ROUND"])
	if "BAG_TAG" in player_pts:
		_setup_bag_tag(player_pts["BAG_TAG"])
	if "MISC" in player_pts:
		_setup_misc(player_pts["MISC"])
	if legacy_pts:
		total_points = legacy_pts
	total_pts_label.text = str(total_points).replace(".", Common.PERIOD)

func _setup_flex(flex_pts: Array) -> void:
	var lowest_pts = 100
	var total_flex_pts = 0
	for pts in flex_pts:
		var node: Label = event_pts_temp_label.duplicate()
		node.visible = true
		if pts < 0:
			node.text = "-"
		else:
			node.text = str(pts).replace(".", Common.PERIOD)
			total_flex_pts += pts
		if pts < lowest_pts:
			lowest_pts = pts
		results_container.add_child(node)
	if lowest_pts > -1:
		total_flex_pts -= lowest_pts
	total_points += total_flex_pts

func _setup_major(major_pts: Array) -> void:
	for pts in major_pts:
		var node: Label = event_pts_temp_label.duplicate()
		node.visible = true
		if pts < 0:
			node.text = "-"
		else:
			node.text = str(pts).replace(".", Common.PERIOD)
		results_container.add_child(node)
	major_pts.sort_custom(func(a, b): return a > b)
	var total_major_pts = 0
	for i in range(2):
		if major_pts[i] > 0:
			total_major_pts += major_pts[i]
	total_points += total_major_pts

func _setup_bag_tag(bag_tag_pts: Array) -> void:
	for pts in bag_tag_pts:
		var node: Label = event_pts_temp_label.duplicate()
		node.visible = true
		if pts < 0:
			node.text = "-"
		else:
			node.text = str(pts).replace(".", Common.PERIOD)
			total_points += pts
		results_container.add_child(node)

func _setup_misc(misc_pts: Array) -> void:
	for pts in misc_pts:
		var node: Label = event_pts_temp_label.duplicate()
		node.visible = true
		if pts < 0:
			node.text = "-"
		else:
			node.text = str(pts).replace(".", Common.PERIOD)
			total_points += pts
		results_container.add_child(node)
