class_name ManageLeagueNode
extends PanelContainer

var event_scene = preload("res://scenes/league/event_entry.tscn")

@export var header_node: HeaderNode
@export var events_container: VBoxContainer

func _ready() -> void:
	header_node.setup("cancel_button", "", "JPDG")#, "Typo Grotesk Rounded Demo.otf")
	header_node.left_pressed.connect(_change_scene.bind("res://scenes/home/home.tscn"))
	var year = str(Time.get_datetime_dict_from_system()["year"])
	for i in range(len(Leagues.get_events("JPDG", year, "MONTHLY_FLEX"))):
		var event_node: EventEntryNode = event_scene.instantiate()
		event_node.setup("MONTHLY_FLEX", i, year)
		events_container.add_child(event_node)
	for i in range(len(Leagues.get_events("JPDG", year, "TWO_ROUND"))):
		var event_node: EventEntryNode = event_scene.instantiate()
		event_node.setup("TWO_ROUND", i, year)
		events_container.add_child(event_node)

func _change_scene(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)
