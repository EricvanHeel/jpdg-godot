class_name CalendarNode
extends PanelContainer

@export var header_node: HeaderNode

func _ready() -> void:
	header_node.setup("home_button", "", "Schedule")
	header_node.left_button.pressed.connect(_home_scene)

func _home_scene() -> void:
	get_tree().change_scene_to_file("res://scenes/home/home.tscn")
