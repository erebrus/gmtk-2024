class_name MapScore extends RefCounted

const ROOM_EXISTS = 0.4
const ROOM_SIZE = 0.3
const ROOM = ROOM_EXISTS + ROOM_SIZE
const DOORS = 0.2
const SPECIAL = 0.1
const EXTRA = 0.1


var correct_checks: Dictionary = {
	"rooms_exist": 0,
	"rooms_size": 0,
	"doors": 0,
	"special": 0,
	"extra": 0,
}
var number_checks: Dictionary = {
	"rooms_exist": 0,
	"rooms_size": 0,
	"doors": 0,
	"special": 0,
	"extra": 0,
}

var rooms_exist: float
var rooms_size: float
var doors: float
var special: float
var extra: float

var rooms: float
var total: float


func check_room_exists(value: bool) -> void:
	_add_check("rooms_exist", value)
	_log_result(value, "There is a room")
	

func check_room_size(value: bool) -> void:
	_add_check("rooms_size", value)
	_log_result(value, "Room is the right size")
	

func check_doors(value: bool) -> void:
	_add_check("doors", value)
	_log_result(value, "Door is where it should")
	

func check_special(value: bool) -> void:
	_add_check("special", value)
	_log_result(value, "Landmark is where it should")
	

func check_extra(value: bool) -> void:
	_add_check("extra", value)
	_log_result(value, "Clue found")
	

func calculate_totals() -> void:
	for factor_name in number_checks:
		self[factor_name] = _get_factor(factor_name)
	
	rooms = (rooms_exist * ROOM_EXISTS + rooms_size * ROOM_SIZE) / ROOM
	
	if has_special():
		total = rooms * ROOM + doors * DOORS + special * SPECIAL
	else:
		total = (rooms * ROOM + doors * DOORS) / (ROOM + DOORS)
	
	total += extra
	

func has_special() -> bool:
	return _is_valid("special")
	

func has_extra() -> bool:
	return _is_valid("extra")
	

func _add_check(score_name: String, value: bool) -> void:
	number_checks[score_name] += 1
	if value:
		correct_checks[score_name] += 1
	

func _get_factor(score_name: String) -> float:
	if number_checks[score_name] == 0:
		return 0
	
	return float(correct_checks[score_name]) / number_checks[score_name]
	

func _is_valid(score_name: String) -> bool:
	return number_checks[score_name] > 0
	

func _log_result(value: bool, msg: String) -> void:
	var result = "PASS" if value else "FAIL"
	Logger.debug("\t%s: %s" % [result, msg])
	

func _to_string() -> String:
	return "Total: %s. Rooms: %s/%s, Sizes: %s/%s, Doors: %s/%s, Special: %s/%s, Extra: %s/%s" % [
		total,
		correct_checks["rooms_exist"], number_checks["rooms_exist"],
		correct_checks["rooms_size"], number_checks["rooms_size"],
		correct_checks["doors"], number_checks["doors"],
		correct_checks["special"], number_checks["special"],
		correct_checks["extra"], number_checks["extra"],
	]
