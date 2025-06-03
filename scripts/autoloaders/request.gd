extends HTTPRequest

func get_rounds(last_login: int) -> Dictionary:
	"""
	Returns:
		{
			"user name": [
				{
					"scores": list[dict],
					"username": str,
					"id": str,
					"course": str,
					"timestamp": int
				}
			]
		}
	"""
	var response = await _post(
		Common.ROUNDS_ENDPOINT,
		{"action": "load", "usernames": Common.PLAYERS, "last_timestamp": last_login}
	)
	response.raise_for_status()
	return response.body["rounds"]

func get_courses(last_login: int) -> Array:
	"""
	Returns:
		[
			{
				"holes": list[dict],
				"last_updated": int,
				"alternates": [],
				"rating": int
			}
		]
	"""
	var response = await _post(
		Common.COURSES_ENDPOINT, {"action": "load", "last_timestamp": last_login}
	)
	response.raise_for_status()
	return response.body["courses"]

func get_leagues(last_login: int, leagues: Array) -> Array:
	"""
	Returns:
		[
			{
				"name": str,
				"abbr": str,
				"admins": list[str],
				"last_updated": int,
				"seasons": {
					int: {
						"events": {}
					}
				}
			}
		]
	"""
	var response = await _post(
		Common.LEAGUES_ENDPOINT, {"action": "load", "last_timestamp": last_login, "leagues": leagues}
	)
	response.raise_for_status()
	return response.body["leagues"]

func post_rounds(rounds: Array) -> void:
	Common.log("Posting %s rounds" % str(len(rounds)))
	var response = await _post(
		Common.ROUNDS_ENDPOINT, {"action": "save", "rounds": rounds}
	)
	response.raise_for_status()

func post_league(league: Dictionary) -> void:
	Common.log("Posting league %s" % league["abbr"])
	var response = await _post(
		Common.LEAGUES_ENDPOINT, {"action": "save", "league": league}
	)
	response.raise_for_status()

func _post(url: String, body: Dictionary) -> Response:
	var headers = ["Content-Type: application/json"]
	var error = request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(body))
	if error:
		Common.log("Request error: %s" % error, "ERROR")
	var signal_response_array = await request_completed
	return Response.new(signal_response_array)
