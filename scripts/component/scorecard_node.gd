class_name ScorecardNode
extends Control

var better_stylebox = preload("res://assets/theme/better.tres")
var birdie_stylebox = preload("res://assets/theme/birdie.tres")
var bogey_stylebox = preload("res://assets/theme/bogey.tres")
var worse_stylebox = preload("res://assets/theme/worse.tres")

@export var first_name_label: Label
@export var course_label: Label
@export var score_diff_label: Label
@export var last_name_label: Label
@export var date_label: Label
@export var rating_label: Label
@export var expand_button: Button
@export var scores_container: GridContainer
@export var score_margin: MarginContainer
@export var animation_player: AnimationPlayer

var over_under: int
var hole_labels: Array
var score_labels: Array
var par_labels: Array
var timestamp: int  # keep for filtering these nodes

func _ready() -> void:
	expand_button.pressed.connect(expand_pressed)

func setup(round: Dictionary) -> void:
	first_name_label.text = round["username"].split(" ", 1)[0]
	course_label.text = round["course"]
	last_name_label.text = round["username"].split(" ", true, 1)[1]
	date_label.text = Common.get_formatted_date(round["timestamp"])
	timestamp = round["timestamp"]
	
	var course = Courses.courses[round["course"]]
	for score in round["scores"]:
		_create_score_labels(score, Courses.get_hole_par(course, score["hole"]))
	for label in hole_labels + score_labels + par_labels:
		scores_container.add_child(label)
	over_under = Common.get_raw_over_under(round)
	score_diff_label.text = Common.format_over_under(over_under)
	rating_label.text = str(course["rating"] + (-10 * over_under))

func expand_pressed() -> void:
	if score_margin.visible:
		animation_player.play("collapse")
	else:
		animation_player.play("expand")

func _create_score_labels(score: Dictionary, par: int) -> void:
	hole_labels.append(_get_generic_label(score["hole"]))
	var score_label = _get_generic_label(str(score["strokes"]))
	score_label.add_theme_color_override("font_color", "ffffff")
	score_label.add_theme_font_size_override("font_size", 50)
	var diff = score["strokes"] - par
	if diff < -1:
		score_label.add_theme_stylebox_override("normal", better_stylebox)
	elif diff == -1:
		score_label.add_theme_stylebox_override("normal", birdie_stylebox)
	elif diff == 1:
		score_label.add_theme_stylebox_override("normal", bogey_stylebox)
	elif diff > 1:
		score_label.add_theme_stylebox_override("normal", worse_stylebox)
	score_labels.append(score_label)
	par_labels.append(_get_generic_label(str(par)))

func _get_generic_label(text: String) -> Label:
	var label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", 38)
	label.add_theme_color_override("font_color", Common.BRIGHT_GREEN)
	return label
