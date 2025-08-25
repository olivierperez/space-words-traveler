extends Node

var current_level: int
var words_speed: FloatRange
var words_spawn_interval: FloatRange
var words_size: IntRange

const MAX_LEVEL:float = 20


func set_level(level: int) -> void:
	self.current_level = level
	words_speed = FloatRange.new(
		_leveled(level, 20, 50), # min
		_leveled(level, 30, 70) # max
	)
	words_spawn_interval = FloatRange.new(
		_leveled(level, 2.5, 2.0), # min
		_leveled(level, 2.0, 1.0) # max
	)
	words_size = IntRange.new(
		_ileveled(level, 3, 5), # min
		_ileveled(level, 3, 15) # max
	)

func rand_words_speed() -> float:
	return randf_range(words_speed.low, words_speed.high)


func rand_words_spawn_interval() -> float:
	return randf_range(words_spawn_interval.low, words_spawn_interval.high)


func allow_word(word: String) -> bool:
	return word.length() >= words_size.low and word.length() <= words_size.high


func increment() -> void:
	set_level(current_level + 1)


func _leveled(level: int, low: float, high: float) -> float:
	var percent = (level - 1) / (MAX_LEVEL - 1) # (1 to 20) -> (0 to 19)
	return low + pow(percent, 2) * (high - low)


func _ileveled(level: int, low: int, high: int) -> int:
	return int(_leveled(level, low, high))


class FloatRange:
	var low: float
	var high: float
	
	func _init(iLow: float, iHigh: float) -> void:
		self.low = iLow
		self.high = iHigh


class IntRange:
	var low: int
	var high: int
	
	func _init(iLow: int, iHigh: int) -> void:
		self.low = iLow
		self.high = iHigh
