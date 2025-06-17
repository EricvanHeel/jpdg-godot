class_name FriendEntryNode
extends HBoxContainer

@export var rounds_label: Label
@export var rating_label: Label
@export var profile_button: Button

func setup(user: String) -> void:
	profile_button.text = user
	var year = str(Time.get_datetime_dict_from_system()["year"])
	rounds_label.text = str(len(Rounds.get_user_rounds_by_year(user, year)))
	var rating = Rounds.get_player_rating(user)
	rating_label.text = str(rating) if rating else "-"
	profile_button.pressed.connect(_change_scene.bind(user))

func _change_scene(user: String) -> void:
	ClientData.profile_user = user
	get_tree().change_scene_to_file("res://scenes/stats/profile.tscn")
