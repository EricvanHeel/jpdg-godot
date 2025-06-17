extends Node

const FILE_PATH = "user://client_data.json"

var last_login: int
var user: String

# Below are used to transfer data to play round scene
var play_round_course: String = ""
var play_round_card: Array = []
var play_round_event_title: String = ""

# Below is used to transfer league to manage
var manage_league: String = "JPDG"

# Below is used to determine who's profile should be loaded
var profile_user: String = ""

func _ready() -> void:
	if not FileAccess.file_exists(FILE_PATH):
		Common.save_dict_as_json({"last_login": 0, "user": ""}, FILE_PATH)
	var client_data = Common.load_json_as_dict(FILE_PATH)
	last_login = client_data["last_login"]
	user = client_data["user"]

func update(_user: String = "", _last_login: int = 0) -> void:
	if _user:
		user = _user
	if _last_login:
		last_login = _last_login
	save()

func save() -> void:
	Common.save_dict_as_json(
		{
			"user": user,
			"last_login": last_login
		},
		FILE_PATH
	)

func log_out() -> void:
	user = ""
	save()

func reset_last_login() -> void:
	last_login = 0
	save()

func clear_play_round() -> void:
	play_round_course = ""
	play_round_card = []
	play_round_event_title = ""
