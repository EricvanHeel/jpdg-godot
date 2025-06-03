class_name Common
extends Node

const PLAYERS = [
	"Ben Duva",
	"Dustin Kaiser",
	"Eric van Heel",
	"Evin Bell",
	"James Polo",
	"Mike James",
	"Nick Pockoski",
	"Pete Newcomb",
	"Rob Newcomb",
	"Sam Lindeyer",
	"Théo Tessier",
	"Tyler Renfro",
	"Zack Cyr",
]

const BASE_URL = "https://1r1bak8xq5.execute-api.us-east-1.amazonaws.com/live"
const ROUNDS_ENDPOINT = BASE_URL + "/rounds"
const COURSES_ENDPOINT = BASE_URL + "/courses"
const LEAGUES_ENDPOINT = BASE_URL + "/leagues"
#const USER_ENDPOINT = BASE_URL + "/user"

const YELLOW = "d1ae1f"
const WHITE = "ffffff"
const DARK_GREEN = "0b2416"
const VERY_DARK = "05120b"
const LIGHT_GREEN = "216e45"
const BRIGHT_GREEN = "33ab6b"

const PERIOD = "․"


static func get_rating(round: Dictionary) -> int:
	var score = get_raw_over_under(round)
	var course = Courses.courses[round["course"]]
	return course["rating"] + (-10 * score)


static func get_raw_over_under(round: Dictionary) -> int:
	var total_par = 0
	var total_strokes = 0
	var course = Courses.courses[round["course"]]
	for score in round["scores"]:
		total_strokes += score["strokes"]
		total_par += Courses.get_hole_par(course, score["hole"])
	return total_strokes - total_par


static func format_over_under(diff: int) -> String:
	if diff < 0:
		return str(diff)
	if diff == 0:
		return "E"
	return "+" + str(diff)


static func get_formatted_date(timestamp: int) -> String:
	var date_dict = Time.get_datetime_dict_from_unix_time(timestamp)
	return "%s/%s/%s" % [date_dict["month"], date_dict["day"], str(date_dict["year"]).replace("20", "")]


static func load_json_as_dict(file_path: String) -> Dictionary:
	var file = FileAccess.open(file_path, FileAccess.READ)
	var dict = JSON.parse_string(file.get_as_text())
	file.close()
	return dict


static func save_dict_as_json(dict: Dictionary, file_path: String) -> void:
	var file = FileAccess.open(file_path, FileAccess.WRITE_READ)
	file.store_line(JSON.stringify(dict, "\t"))
	file.close()


static func save_array_as_json(array: Array, file_path: String) -> void:
	var file = FileAccess.open(file_path, FileAccess.WRITE_READ)
	file.store_line(JSON.stringify(array, "\t"))
	file.close()


static func log(message: String, level: String = "INFO", should_throw: bool = true) -> void:
	print("%s | %s" % [level, message])
	if level == "ERROR" and should_throw:
		assert(false)

const MONTH = {
	1: "January", 2: "February", 3: "March", 4: "April", 5: "May", 6: "June",
	7: "July", 8: "August", 9: "September", 10: "October", 11: "November", 12: "December"
}
