class_name Response
extends RefCounted

var status_code: int
var body: Dictionary

func _init(signal_response_array: Array) -> void:
	status_code = signal_response_array[1]
	body = JSON.parse_string(signal_response_array[3].get_string_from_utf8())

func raise_for_status() -> void:
	if status_code >= 300:
		Common.log(
			"HTTP %s | %s" % [status_code, body["message"]],
			"ERROR",
			true
		)
