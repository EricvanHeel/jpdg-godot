class_name HomeNode
extends Control

var scorecard_scene = preload("res://scenes/component/scorecard.tscn")
var standings_scene = preload("res://scenes/home/league_standing.tscn")

@export var animation_player: AnimationPlayer

@export var profile_button: Button
@export var feed_button: Button
@export var pro_tour_button: Button

@export var panel_feed: PanelContainer
@export var feed_container: VBoxContainer
@export var no_rounds_label: Label
@export var sort_filter: OptionButton
@export var time_filter: OptionButton
@export var users_filter: OptionButton

@export var standings_title: Label
@export var standings_container: VBoxContainer
@export var standings_prev_button: Button
@export var standings_next_button: Button

@export var menu_button: Button
@export var space_button: Button
@export var close_menu_button: Button
@export var casual_round_button: Button
@export var flex_round_button: Button
@export var major_round_button: Button
@export var league_schedule_button: Button
@export var manage_league_button: Button
@export var sync_data_button: Button
@export var log_out_button: Button

var last_animation: String = "main_feed"
var standings_year: int = 0

func _ready() -> void:
	profile_button.pressed.connect(_change_scene.bind("res://scenes/stats/profile.tscn"))
	
	# Setup standings
	var league_standings: LeagueStandingNode = standings_scene.instantiate()
	standings_year = Time.get_datetime_dict_from_system()["year"]
	standings_title.text = "%s Pro Tour" % str(standings_year)
	league_standings.setup(standings_year)
	standings_container.add_child(league_standings)
	pro_tour_button.pressed.connect(_play_animation.bind("pro_tour"))
	standings_prev_button.pressed.connect(_prev_pro_tour)
	standings_next_button.pressed.connect(_next_pro_tour)
	standings_prev_button.disabled = !str(standings_year - 1) in Leagues.leagues["JPDG"]["seasons"]
	
	# Setup rounds feed
	sort_filter.item_selected.connect(_get_rounds)
	time_filter.item_selected.connect(_get_rounds)
	users_filter.item_selected.connect(_get_rounds)
	#_sort_and_add_scorecards(Rounds.get_rounds_this_month())
	_sort_and_add_scorecards(Rounds.get_rounds_last_n_days(30))
	feed_button.pressed.connect(_play_animation.bind("main_feed"))
	
	# Setup menu
	menu_button.pressed.connect(_expand_menu)
	space_button.pressed.connect(_collapse_menu)
	close_menu_button.pressed.connect(_collapse_menu)
	sync_data_button.pressed.connect(_sync_data)
	log_out_button.pressed.connect(_log_out)
	casual_round_button.pressed.connect(_change_scene.bind("res://scenes/play/play_casual.tscn"))
	if Leagues.is_member(ClientData.user):
		var flex = Leagues.get_current_flex()
		if flex:
			flex_round_button.text = Common.MONTH[Time.get_datetime_dict_from_system()["month"]] + " Flex"
			flex_round_button.visible = true
			flex_round_button.pressed.connect(_change_scene.bind("res://scenes/play/play_flex.tscn"))
		var major = Leagues.get_current_two_round()
		if major:
			major_round_button.text = major["name"]
			major_round_button.visible = true
			major_round_button.pressed.connect(_change_scene.bind("res://scenes/play/play_major.tscn"))
		if Leagues.is_admin(ClientData.user, "JPDG"):
			manage_league_button.visible = true
			manage_league_button.pressed.connect(_change_scene.bind("res://scenes/league/manage_league.tscn"))
	league_schedule_button.pressed.connect(_change_scene.bind("res://scenes/calendar/calendar.tscn"))

func _sort_and_add_scorecards(rounds: Array) -> void:
	for child in feed_container.get_children():
		if is_instance_of(child, ScorecardNode):
			feed_container.remove_child(child)
			child.queue_free()
	if not rounds:
		no_rounds_label.visible = true
		return
	no_rounds_label.visible = false
	var scoredcard_nodes = []
	for round in rounds:
		var node: ScorecardNode = scorecard_scene.instantiate()
		node.setup(round)
		scoredcard_nodes.append(node)
	match sort_filter.selected:
		0:  # Top Rating
			scoredcard_nodes.sort_custom(func(a, b): return int(a.rating_label.text) > int(b.rating_label.text))
		1:  # Top Strokes
			scoredcard_nodes.sort_custom(func(a, b): return a.over_under < b.over_under)
		2:  # Recent
			scoredcard_nodes.sort_custom(func(a, b): return a.timestamp > b.timestamp)
	for node in scoredcard_nodes:
		if feed_container.get_child_count() == 16:  # Limit to 15 rounds
			break
		feed_container.add_child(node)

func _get_rounds(index: int) -> void:
	var users = [ClientData.user] if users_filter.selected else []
	match time_filter.selected:
		0:
			#_sort_and_add_scorecards(Rounds.get_rounds_this_month(users))
			_sort_and_add_scorecards(Rounds.get_rounds_last_n_days(30, users))
		1:
			_sort_and_add_scorecards(Rounds.get_rounds_last_n_days(90, users))
		2:
			_sort_and_add_scorecards(Rounds.get_rounds_this_year(users))
		3:
			_sort_and_add_scorecards(Rounds.get_rounds_last_n_days(365, users))
	animation_player.play("sort_rounds")

func _prev_pro_tour() -> void:
	var node: LeagueStandingNode = standings_container.get_children()[1]
	standings_container.remove_child(node)
	standings_year -= 1
	var league_standings: LeagueStandingNode = standings_scene.instantiate()
	league_standings.setup(standings_year)
	standings_container.add_child(league_standings)
	standings_title.text = "%s Pro Tour" % str(standings_year)
	standings_next_button.disabled = false
	standings_prev_button.disabled = !str(standings_year - 1) in Leagues.leagues["JPDG"]["seasons"]
	league_standings.animation_player.play("fade_in")

func _next_pro_tour() -> void:
	var node: LeagueStandingNode = standings_container.get_children()[1]
	standings_container.remove_child(node)
	standings_year += 1
	var league_standings: LeagueStandingNode = standings_scene.instantiate()
	league_standings.setup(standings_year)
	standings_container.add_child(league_standings)
	standings_title.text = "%s Pro Tour" % str(standings_year)
	standings_prev_button.disabled = false
	standings_next_button.disabled = !str(standings_year + 1) in Leagues.leagues["JPDG"]["seasons"]
	league_standings.animation_player.play("fade_in")

func _sync_data() -> void:
	ClientData.reset_last_login()
	Courses.reset()
	Leagues.reset()
	Rounds.reset()
	_change_scene("res://scenes/start/start.tscn")

func _log_out() -> void:
	ClientData.log_out()
	_change_scene("res://scenes/start/start.tscn")

func _play_animation(animation: String) -> void:
	if last_animation != animation:
		animation_player.play(animation)
		last_animation = animation

func _change_scene(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)

func _expand_menu() -> void:
	animation_player.play("expand_menu")

func _collapse_menu() -> void:
	animation_player.play("collapse_menu")
