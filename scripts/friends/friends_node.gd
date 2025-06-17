class_name FriendNode
extends PanelContainer

var friend_scene = preload("res://scenes/friends/friend_entry.tscn")

@export var header: HeaderNode
@export var friends_container: VBoxContainer

func _ready() -> void:
	header.setup("home_button", "profile_button", "Friends", "Autography.otf")
	header.title_label.add_theme_font_size_override("font_size", 128)
	header.left_button.pressed.connect(_go_home)
	header.right_button.pressed.connect(_user_profile)
	var entry_nodes = []
	for user in Common.PLAYERS:
		if user != ClientData.user:
			var node: FriendEntryNode = friend_scene.instantiate()
			node.setup(user)
			entry_nodes.append(node)
	entry_nodes.sort_custom(func(a, b): return int(a.rounds_label.text) > int(b.rounds_label.text))
	for node: FriendEntryNode in entry_nodes:
		node.modulate = "ffffff00"
		friends_container.add_child(node)
		var tween := create_tween()
		tween.tween_property(node, "modulate", Color("ffffff"), 0.2) # Fade in 1 second
		await get_tree().create_timer(0.1).timeout

func _go_home() -> void:
	get_tree().change_scene_to_file("res://scenes/home/home.tscn")

func _user_profile() -> void:
	ClientData.profile_user = ClientData.user
	get_tree().change_scene_to_file("res://scenes/stats/profile.tscn")
