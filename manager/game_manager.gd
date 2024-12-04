extends Node

##################################################
var best: int = 0	# 최고 점수
var score: int = 0	# 현재 점수

##################################################
func _ready() -> void:
	load_score()	# 최고 점수 불러오기

##################################################
func set_best(value: int) -> void:	# 최고 점수 수정
	best = value

##################################################
func set_score(value: int) -> void:	# 현재 점수 수정
	score = value
	
##################################################
func save_score() -> void:	# 현재 점수를 최고 저뭇와 비교하여 저장
	if best <= score:
		best = score
		var save_file = ConfigFile.new()
		save_file.set_value("game", "score", best)
		save_file.save("user://score.cfg")

##################################################
func load_score() -> void:	# 최고 점수 불러오기
	var loaded_file = ConfigFile.new()
	if loaded_file.load("user://score.cfg") == OK:
		best = loaded_file.get_value("game", "score", best)
