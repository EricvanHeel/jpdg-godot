extends Node

const FILE_PATH = "user://leagues.json"

var leagues = {}

func _ready() -> void:
	if not FileAccess.file_exists(FILE_PATH):
		Common.save_dict_as_json({}, FILE_PATH)
	leagues = Common.load_json_as_dict(FILE_PATH)

func is_member(user: String, abbr: String = "JPDG") -> bool:
	return user in members(abbr)

func members(abbr: String = "JPDG") -> Array:
	var league = Leagues.leagues[abbr]
	return league["admins"] + league["players"]

func add_finish_to_event(type: String, index: int, year: String, finish: Dictionary, league: String = "JPDG") -> void:
	leagues[league]["seasons"][year]["events"][type][index]["finish"] = finish
	leagues[league]["last_updated"] = int(Time.get_unix_time_from_system())
	save()
	await Request.post_league(leagues[league])

func add_rounds_to_current_flex(rounds: Array, league: String = "JPDG") -> void:
	var date = Time.get_datetime_dict_from_system()
	for event in leagues[league]["seasons"][str(date["year"])]["events"]["MONTHLY_FLEX"]:
		if event["month"] == date["month"]:
			for round in rounds:
				if round["username"] not in event["rounds"]:
					event["rounds"][round["username"]] = [round["id"]]
					continue
				if len(event["rounds"][round["username"]]) < 2:
					event["rounds"][round["username"]].append(round["id"])
	leagues[league]["last_updated"] = int(Time.get_unix_time_from_system())
	save()
	await Request.post_league(leagues[league])

func get_current_flex(league: String = "JPDG") -> Dictionary:
	var month = Time.get_datetime_dict_from_system()["month"]
	var events = get_events(league, str(Time.get_datetime_dict_from_system()["year"]), "MONTHLY_FLEX")
	var event = events.filter(func(x): return x["month"] == month)
	if not event:
		return {}
	if len(event) > 1:
		Common.log("Found multiple flex events for league %s in month %s" % [league, month])
	return event[0]

func get_current_two_round(league: String = "JPDG") -> Dictionary:
	var date = Time.get_date_string_from_system()
	var events = get_events(league, date.split("-")[0], "TWO_ROUND")
	var event = events.filter(func(x): return x["date"] == date)
	if not event:
		return {}
	if len(event) > 1:
		Common.log("Found multiple majors for league %s on %s" % [league, date])
	return event[0]

func get_events(league: String, year: String, type: String) -> Array:
	if year not in leagues["JPDG"]["seasons"]:
		return []
	if type not in leagues["JPDG"]["seasons"][year]["events"]:
		return []
	return leagues["JPDG"]["seasons"][year]["events"][type]

func is_admin(username: String, league: String) -> bool:
	return username in leagues[league]["admins"]

func load_jpdg_from_remote() -> void:
	var updated_leagues = await Request.get_leagues(ClientData.last_login, ["JPDG"])
	for league in updated_leagues:
		Common.log("Found updated league %s" % league["abbr"])
		leagues[league["abbr"]] = league
	save()

func save() -> void:
	Common.save_dict_as_json(leagues, FILE_PATH)

func reset() -> void:
	leagues = {}
	save()
