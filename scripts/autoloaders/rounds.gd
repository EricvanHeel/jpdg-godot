extends Node

const FILE_PATH = "user://rounds.json"

var rounds: Dictionary

func _ready() -> void:
	if not FileAccess.file_exists(FILE_PATH):
		Common.save_dict_as_json({}, FILE_PATH)
	rounds = Common.load_json_as_dict(FILE_PATH)

func get_player_rating(player_name: String) -> int:
	var ratings = []
	for days in [90, 60, 30]:
		var valid_rounds = get_rounds_last_n_days(days, [player_name])
		for round in valid_rounds:
			ratings.append(Common.get_rating(round))
	if len(ratings) < 12:
		return 0
	var total_rating = ratings.reduce(func(accum, number): return accum + number, 0)
	var avg_rating = float(total_rating) / len(ratings)
	return round(avg_rating)

func get_round_by_uuid(player_name: String, course_name: String, year: String, uuid: String) -> Dictionary:
	var filter_rounds = rounds[player_name][course_name][year]
	#var index = filter_rounds.find_custom(func(x): return x["id"] == uuid) # find custom in 4.4
	var round = filter_rounds.filter(func(round): return round["id"] == uuid)
	if len(round) != 1:
		Common.log("Found %s rounds for id '%s'" % [len(round), uuid], "ERROR")
	return round[0]

func get_hole_average(course_name: String, hole: String, players: Array = Common.PLAYERS) -> float:
	var strokes = []
	var filtered_rounds = filter_rounds_by_course(course_name, players)
	for round in filtered_rounds:
		for score in round["scores"]:
			if score["hole"] == hole:
				strokes.append(score["strokes"])
	if not strokes:
		return 0
	var total = float(strokes.reduce(func(accum, number): return accum + number))
	return total / len(strokes)

func filter_rounds_by_course(filter_course: String, players: Array = Common.PLAYERS) -> Array:
	var filtered_rounds = []
	for player in players:
		if player in rounds and filter_course in rounds[player]:
			for year in rounds[player][filter_course]:
				filtered_rounds.append_array(rounds[player][filter_course][year])
	return filtered_rounds

func get_rounds_this_month(users: Array = []) -> Array:
	var now = Time.get_datetime_dict_from_system()
	var min_timestamp = Time.get_unix_time_from_datetime_dict(
		{"month": now["month"], "year": now["year"]}
	)
	var next_month = now["month"] + 1 if now["month"] < 12 else 1
	var max_timestamp = Time.get_unix_time_from_datetime_dict(
		{"month": next_month, "year": now["year"]}
	)
	return _get_rounds_by_timestamp(min_timestamp, max_timestamp, [str(now["year"])], users)

func get_rounds_last_n_days(num_days: int, users: Array = []) -> Array:
	var now = Time.get_unix_time_from_system()
	var min_timestamp = now - (num_days * 86400)
	var min_year = str(Time.get_datetime_dict_from_unix_time(min_timestamp)["year"])
	var years = [str(Time.get_datetime_dict_from_system()["year"])]
	if min_year not in years:
		years.append(min_year)
	return _get_rounds_by_timestamp(min_timestamp, now, years, users)

func get_rounds_this_year(users: Array = []) -> Array:
	var now = Time.get_unix_time_from_system()
	var year = Time.get_datetime_dict_from_system()["year"]
	var min_timestamp = Time.get_unix_time_from_datetime_dict(
		{"year": year}
	)
	return _get_rounds_by_timestamp(min_timestamp, now, [str(year)], users)

func _get_rounds_by_timestamp(
	min_timestamp: int, max_timestamp: int, years: Array, users: Array = []
) -> Array:
	#print(min_timestamp)
	#print(max_timestamp)
	#print(users)
	var filtered_rounds = []
	for user in rounds:
		if users and user not in users:
			continue
		for course in rounds[user]:
			for year in years:
				if year not in rounds[user][course]:
					continue
				for round in rounds[user][course][year]:
					if round["timestamp"] >= min_timestamp and round["timestamp"] < max_timestamp:
						filtered_rounds.append(round)
	return filtered_rounds

func get_all_rounds_by_user(user: String) -> Array:
	var user_rounds = []
	for course in rounds[user]:
		for year in rounds[user][course]:
			user_rounds.append_array(rounds[user][course][year])
	return user_rounds

func load_latest_rounds_from_remote() -> void:
	var remote_rounds_dict = await Request.get_rounds(ClientData.last_login)
	for user in remote_rounds_dict:
		if not remote_rounds_dict[user]:  # Users without updates will come back with empty list
			continue
		Common.log("Found %s new rounds for user %s" % [len(remote_rounds_dict[user]), user])
		for round in remote_rounds_dict[user]:
			var year = str(Time.get_datetime_dict_from_unix_time(round["timestamp"])["year"])
			if user not in rounds:
				rounds[user] = {
					round["course"]: {
						year: [round]
					}
				}
				continue
			if round["course"] not in rounds[user]:
				rounds[user][round["course"]] = {
					year: [round]
				}
				continue
			if year not in rounds[user][round["course"]]:
				rounds[user][round["course"]][year] = [round]
				continue
			rounds[user][round["course"]][year].append(round)
	save()

func save() -> void:
	Common.save_dict_as_json(rounds, FILE_PATH)

func reset() -> void:
	rounds = {}
	save()
