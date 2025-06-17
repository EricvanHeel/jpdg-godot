class_name ManageLeagueNode
extends PanelContainer

var event_scene = preload("res://scenes/league/event_entry.tscn")

@export var header_node: HeaderNode
@export var events_container: VBoxContainer
func _ready() -> void:
	header_node.setup("home_button", "", "JPDG")#, "Typo Grotesk Rounded Demo.otf")
	header_node.left_pressed.connect(_change_scene.bind("res://scenes/home/home.tscn"))
	var year = str(Time.get_datetime_dict_from_system()["year"])
	
	var flex_label = Label.new()
	flex_label.text = "Flex Series"
	flex_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	events_container.add_child(flex_label)
	for i in range(len(Leagues.get_events("JPDG", year, "MONTHLY_FLEX"))):
		var event_node: EventEntryNode = event_scene.instantiate()
		event_node.setup("MONTHLY_FLEX", i, year)
		events_container.add_child(event_node)
		if ClientData.user not in Leagues.leagues["JPDG"]["admins"]:
			event_node.complete_event_button.visible = false
	
	# TODO: this separation line is hardcoded
	#events_container.move_child(panel_separator, -1)
	
	var major_label = Label.new()
	major_label.text = "Majors"
	major_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	events_container.add_child(major_label)
	for i in range(len(Leagues.get_events("JPDG", year, "TWO_ROUND"))):
		var event_node: EventEntryNode = event_scene.instantiate()
		event_node.setup("TWO_ROUND", i, year)
		events_container.add_child(event_node)
		if ClientData.user not in Leagues.leagues["JPDG"]["admins"]:
			event_node.complete_event_button.visible = false
func _change_scene(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)
