class_name ScoreNode
extends Control

var birdie_stylebox = preload("res://assets/theme/birdie.tres")
var worse_stylebox = preload("res://assets/theme/worse.tres")

@export var first_name_label: Label
@export var current_over_under: Label
@export var current_strokes_container: PanelContainer
@export var current_strokes_label: Label
@export var subtract_button: Button
@export var add_button: Button
@export var animation_player: AnimationPlayer

var latest_hole_index: int = 0
var current_hole_index: int = 0
var round: Dictionary
var course: Dictionary

func setup(username: String, _course: Dictionary) -> void:
	add_button.pressed.connect(_add_stroke)
	subtract_button.pressed.connect(_subtract_stroke)
	first_name_label.text = username.split(" ", 1)[0]
	current_over_under.text = "E"
	
	course = _course
	round = {
		"course": course["name"],
		"id": UUID.v4(),
		"scores": [],
		"timestamp": int(Time.get_unix_time_from_system()),  # Overridden when submitting
		"username": username
	}
	# Initialize round scores to even par with non-alt holes
	for i in range(len(course["holes"])):
		var hole = str(i + 1)
		round["scores"].append({
			"hole": hole,
			"strokes": course["holes"][hole]["par"]
		})
	current_strokes_label.text = str(round["scores"][current_hole_index]["strokes"])

func set_alt(hole_name: String, par: int) -> void:
	round["scores"][current_hole_index] = {"hole": hole_name, "strokes": par}
	_update_stroke()

func next_hole() -> void:
	current_hole_index += 1
	current_strokes_label.text = str(round["scores"][current_hole_index]["strokes"])
	if latest_hole_index < current_hole_index:
		latest_hole_index += 1
		current_strokes_label.add_theme_color_override("font_color", "216e45")
		current_strokes_container.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	else:
		current_strokes_label.add_theme_color_override("font_color", Common.WHITE)
		_set_score_panel()
	animation_player.play("fade_in")

func prev_hole() -> void:
	current_hole_index -= 1
	current_strokes_label.text = str(round["scores"][current_hole_index]["strokes"])
	current_strokes_label.add_theme_color_override("font_color", Common.WHITE)
	_set_score_panel()
	animation_player.play("fade_in")

func _set_score_panel() -> void:
	var diff = round["scores"][current_hole_index]["strokes"] - Courses.get_hole_par(course, round["scores"][current_hole_index]["hole"])
	if diff < 0:
		current_strokes_container.add_theme_stylebox_override("panel", birdie_stylebox)
	elif diff == 0:
		current_strokes_container.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	else:
		current_strokes_container.add_theme_stylebox_override("panel", worse_stylebox)

func _add_stroke() -> void:
	round["scores"][current_hole_index]["strokes"] += 1
	_update_stroke()
	subtract_button.disabled = false

func _subtract_stroke() -> void:
	round["scores"][current_hole_index]["strokes"] -= 1
	if round["scores"][current_hole_index]["strokes"] == 1:
		subtract_button.disabled = true
	_update_stroke()

func _update_stroke() -> void:
	current_strokes_label.text = str(round["scores"][current_hole_index]["strokes"])
	current_strokes_label.add_theme_color_override("font_color", Common.WHITE)
	_set_score_panel()
	current_over_under.text = Common.format_over_under(Common.get_raw_over_under(round))























#EOF
