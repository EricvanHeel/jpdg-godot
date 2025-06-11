extends Node

const FILE_PATH = "user://courses.json"

var courses: Dictionary

func _ready() -> void:
	if not FileAccess.file_exists(FILE_PATH):
		Common.save_dict_as_json({}, FILE_PATH)
	courses = Common.load_json_as_dict(FILE_PATH)

func get_course_average(course_name: String, players: Array = Common.PLAYERS) -> String:
	var course = courses[course_name]
	var round_scores: Array = []
	for round in Rounds.filter_rounds_by_course(course_name, players):
		var total_par = 0
		var total_strokes = 0
		for score in round["scores"]:
			total_strokes += score["strokes"]
			total_par += get_hole_par(course, score["hole"])
		round_scores.append(total_strokes - total_par)
	if not round_scores:
		return "-"
	var total = float(round_scores.reduce(func(accum, number): return accum + number))
	var avg: float = total / len(round_scores)
	var plus = "+" if avg > 0 else ""
	return (plus + "%.1f" % avg).replace(".", Common.PERIOD)

func get_hole_par(course: Dictionary, hole: String) -> int:
	if hole in course["holes"]:
		return course["holes"][hole]["par"]
	elif hole in course["alternates"]:
		return course["alternates"][hole]["par"]
	elif "a" in hole or "b" in hole or "c" in hole:
		# Legacy rounds don't have new alt setup
		var new_hole = hole.replace("a", "-a").replace("b", "-b").replace("c", "-c")
		if new_hole in course["alternates"]:
			return course["alternates"][new_hole]["par"]
		else:
			Common.log("Can't find hole '%s' for course %s" % [new_hole, course["name"]])
	else:
		Common.log("Can't find hole '%s' for course %s" % [hole, course["name"]])
	return 100

func load_courses_from_remote() -> void:
	var updated_courses: Array = await Request.get_courses(ClientData.last_login)
	for course_dict in updated_courses:
		Common.log("Found updated course %s" % course_dict["name"])
		courses[course_dict["name"]] = course_dict
	save()

func save() -> void:
	Common.save_dict_as_json(courses, FILE_PATH)

func reset() -> void:
	courses = {}
	save()
