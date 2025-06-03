class_name StandingsEntryNode
extends Control

@export var total_pts_label: Label
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

var total_points: float = 0
var username: String

func setup(pts: Array, user: String) -> void:
	username = user
	var events_labels = [
		flex_1_label, flex_2_label, flex_3_label, flex_4_label, flex_5_label,
		flex_6_label, major_1_label, major_2_label, major_3_label, major_4_label
	]
	# TODO: drop worst finish when calculating total points
	for i in range(len(events_labels)):
		if pts[i] < 0:
			events_labels[i].text = "-"
		else:
			events_labels[i].text = str(pts[i]).replace(".", Common.PERIOD)
			total_points += pts[i]
	total_pts_label.text = str(total_points).replace(".", Common.PERIOD)
