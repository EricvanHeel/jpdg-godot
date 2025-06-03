class_name StartNode
extends Control

var BUTTON_GROUP = ButtonGroup.new()

@export var animation_player: AnimationPlayer
@export var names_container: VBoxContainer
@export var login_button: Button
@export var login_container: VBoxContainer
@export var dummy_player_button: Button
@export var loading_node: LoadingNode
@export var startup_message: Label

var current_player: String

func _ready() -> void:
	startup_message.text = "hello %s!" % ClientData.user.split(" ")[0]
	animation_player.animation_finished.connect(_display_players)
	
	if ClientData.user:
		animation_player.play("startup")
	else:
		animation_player.play("expand")

func _add_player_button(player: String) -> void:
	var button = dummy_player_button.duplicate()
	button.visible = true
	button.text = player
	button.pressed.connect(_player_pressed.bind(player))
	names_container.add_child(button)

func _display_players(animation_name: String) -> void:
	match animation_name:
		"expand":
			for player in Common.PLAYERS:
				_add_player_button(player)
			animation_player.play("players")
		"startup":
			current_player = ClientData.user
			_login()

func _player_pressed(player: String) -> void:
	if current_player:
		current_player = player
		return
	current_player = player
	login_button.pressed.connect(_login)
	login_button.text = "login"
	animation_player.play("login")

func _login() -> void:
	login_container.visible = false
	loading_node.animation_player.play("loading")
	Common.log("Logging in | %s" % current_player)
	await Rounds.load_latest_rounds_from_remote()
	await Courses.load_courses_from_remote()
	await Leagues.load_jpdg_from_remote()
	ClientData.update(current_player, Time.get_unix_time_from_system())
	get_tree().change_scene_to_file("res://scenes/home/home.tscn")
