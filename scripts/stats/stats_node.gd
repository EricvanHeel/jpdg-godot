class_name StatsNode
extends PanelContainer

@export var title_label: Label
@export var button: Button
@export var animation_player: AnimationPlayer

@export var rating_label: Label
@export var score_label: Label
@export var no_rounds_label: Label

@export var bar_container: GridContainer
@export var below_bar: ColorRect
@export var par_bar: ColorRect
@export var bogey_bar: ColorRect
@export var worse_bar: ColorRect

@export var below_pct: Label
@export var par_pct: Label
@export var bogey_pct: Label
@export var worse_pct: Label

var expanded: bool = false
var rounds: Array = []
var num_below: int = 0
var num_par: int = 0
var num_bogey: int = 0
var num_worse: int = 0
var ratings: Array = []
var scores: Array = []

func setup(title: String, expand: bool = false, players: Array = [Common.PLAYERS], years: Array = [], courses: Array = []) -> void:
	title_label.text = title
	button.pressed.connect(_expand_collapse)
	for player in players:
		if player not in Rounds.rounds:
			continue
		for course in Rounds.rounds[player]:
			if courses and course not in courses:
				continue
			for year in Rounds.rounds[player][course]:
				if years and year not in years:
					continue
				rounds.append_array(Rounds.rounds[player][course][year])
	if rounds:
		_process_rounds()
		_set_bars()
	else:
		no_rounds_label.visible = true
		bar_container.visible = false
	if expand:
		_expand_collapse()

func _expand_collapse() -> void:
	if expanded:
		animation_player.play("collapse")
	else:
		animation_player.play("expand")
	expanded = !expanded

func _process_rounds() -> void:
	for round in rounds:
		var score = Common.get_raw_over_under(round)
		var course = Courses.courses[round["course"]]
		var rating = course["rating"] + (-10 * score)
		scores.append(score)
		ratings.append(rating)
		for hole_score in round["scores"]:
			var diff = hole_score["strokes"] - Courses.get_hole_par(course, hole_score["hole"])
			if diff < 0:
				num_below += 1
			elif diff == 0:
				num_par += 1
			elif diff == 1:
				num_bogey += 1
			else:
				num_worse += 1
	var total_score = scores.reduce(func(accum, number): return accum + number, 0)
	var avg_score = float(total_score) / len(scores)
	var total_rating = ratings.reduce(func(accum, number): return accum + number, 0)
	var avg_rating = float(total_rating) / len(ratings)
	var plus = "+" if avg_rating > 0 else ""
	score_label.text = ("%s%0.1f" % [plus, avg_score]).replace(".", Common.PERIOD)
	rating_label.text = str(round(avg_rating))

func _set_bars() -> void:
	var max_num = 0
	var total_num = 0
	for num in [num_below, num_par, num_bogey, num_worse]:
		total_num += num
		if num > max_num:
			max_num = num
	below_bar.custom_minimum_size = Vector2(64, 128 * (float(num_below) / max_num))
	par_bar.custom_minimum_size = Vector2(64, 128 * (float(num_par) / max_num))
	bogey_bar.custom_minimum_size = Vector2(64, 128 * (float(num_bogey) / max_num))
	worse_bar.custom_minimum_size = Vector2(64, 128 * (float(num_worse) / max_num))
	
	below_pct.text = "%d%%" % round((float(num_below) / total_num) * 100)
	par_pct.text = "%d%%" % round((float(num_par) / total_num) * 100)
	bogey_pct.text = "%d%%" % round((float(num_bogey) / total_num) * 100)
	worse_pct.text = "%d%%" % round((float(num_worse) / total_num) * 100)



















# EOF
