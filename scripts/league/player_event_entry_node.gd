class_name PlayerEventEntryNode
extends HBoxContainer

@export var name_label: Label
@export var score_label: Label
@export var place_edit: LineEdit
@export var points_edit: LineEdit

func setup(username: String, score: String, place: String, points: String, editable: bool) -> void:
	name_label.text = username
	score_label.text = score
	place_edit.placeholder_text = place
	points_edit.placeholder_text = points.replace(".", "․")
	place_edit.editable = editable
	points_edit.editable = editable
