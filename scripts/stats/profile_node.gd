class_name ProfileNode
extends PanelContainer

var stats_scene = preload("res://scenes/stats/stats.tscn")
var scorecard_scene = preload("res://scenes/component/scorecard.tscn")

@export var header: HeaderNode
@export var main_container: VBoxContainer
@export var top_rounds_this_year: VBoxContainer

@export var rounds_recorded: Label
@export var courses_played: Label
@export var current_rating: Label
@export var no_rounds_label: Label

var prev_avg_strokes: Dictionary
var prev_ratings: Dictionary
var top_rounds_strokes: Array
var top_rounds_rating: Array

func _ready() -> void:
	header.setup("home_button", "", ClientData.profile_user, "Autography.otf")
	header.title_label.add_theme_font_size_override("font_size", 128)
	header.left_button.pressed.connect(_go_home)
	
	rounds_recorded.text = str(len(Rounds.get_all_rounds_by_user(ClientData.profile_user)))
	var rating = Rounds.get_player_rating(ClientData.profile_user)
	current_rating.text = str(rating) if rating else "-"
	courses_played.text = str(len(Rounds.rounds[ClientData.profile_user]))
	
	var stats_node: StatsNode = stats_scene.instantiate()
	var current_year = str(Time.get_datetime_dict_from_system()["year"])
	stats_node.setup("%s Stats" % current_year, true, [ClientData.profile_user], [current_year])
	main_container.add_child(stats_node)
	main_container.move_child(stats_node, 0)
	
	stats_node.rounds.sort_custom(func(a, b): return Common.get_rating(a) > Common.get_rating(b))
	if not stats_node.rounds:
		no_rounds_label.visible = true
	for i in range(3):
		if i < len(stats_node.rounds):
			var scorecard_node: ScorecardNode = scorecard_scene.instantiate()
			scorecard_node.setup(stats_node.rounds[i])
			top_rounds_this_year.add_child(scorecard_node)
	
	var year = int(current_year) - 1
	while year > 2022:
		var prev_stats_node: StatsNode = stats_scene.instantiate()
		prev_stats_node.setup("%s Stats" % str(year), false, [ClientData.profile_user], [str(year)])
		if prev_stats_node.rounds:
			main_container.add_child(prev_stats_node)
		year -= 1

func _go_home() -> void:
	get_tree().change_scene_to_file("res://scenes/home/home.tscn")
