class_name CalendarNode
extends PanelContainer

@export var header_node: HeaderNode
@export var events_container: VBoxContainer
@export var event_title_temp: Label
@export var flex_event_temp: HBoxContainer
@export var two_round_temp: VBoxContainer

func _ready() -> void:
	header_node.setup("home_button", "", "Schedule")
	header_node.left_button.pressed.connect(_home_scene)
	var year = str(Time.get_datetime_dict_from_system()["year"])
	if year in Leagues.leagues["JPDG"]["seasons"]:
		var events_dict = Leagues.leagues["JPDG"]["seasons"][year]["events"]
		for event_type in Common.EVENT_COLORS:
			if event_type in events_dict:
				var title_node = event_title_temp.duplicate()
				title_node.visible = true
				title_node.text = Common.EVENT_NAMES[event_type]
				events_container.add_child(title_node)
				for event in events_dict[event_type]:
					var node
					match event_type:
						"MONTHLY_FLEX":
							node = flex_event_temp.duplicate()
							node.get_children()[0].text = Common.MONTH[int(event["month"])]
							node.get_children()[1].text = event["course"]
						"TWO_ROUND":
							node = two_round_temp.duplicate()
							var date = Common.get_written_date(event["date"])
							node.get_children()[0].text = "%s - %s" % [event["name"], date]
							var courses: Array = []
							for course in event["courses"]:
								courses.append(course.split(" (")[0])
							node.get_children()[1].text = " & ".join(courses)
					node.visible = true
					events_container.add_child(node)

func _home_scene() -> void:
	get_tree().change_scene_to_file("res://scenes/home/home.tscn")
