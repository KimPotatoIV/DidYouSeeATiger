extends Node2D

##################################################
const top_margin: int = 100	# 상단 HUD 영역
const grid_size: int = 4		# 가로 세로 각각 블록 개수

@onready var move_audio_player: AudioStreamPlayer2D = $MoveAudioStreamPlayer2D	# 블록 이동 오디오
@onready var error_audio_player: AudioStreamPlayer2D = $ErrorAudioStreamPlayer2D2	# 블록 이동 불가 오디오
@onready var hud = $"../HUD"	# HUD 노드

var grid: Dictionary = {}	# grid_size에 따른 그리드 딕셔너리
var image_paths: Dictionary = {
	"0": "res://scenes/grid/grid_0.png",			# 나비
	"2": "res://scenes/grid/grid_2.png",			# 토끼
	"4": "res://scenes/grid/grid_4.png",			# 잠자리
	"8": "res://scenes/grid/grid_8.png",			# 고양이
	"16": "res://scenes/grid/grid_16.png",		# 악어
	"32": "res://scenes/grid/grid_32.png",		# 뱀
	"64": "res://scenes/grid/grid_64.png",		# 독거미
	"128": "res://scenes/grid/grid_128.png",		# 늑대
	"256": "res://scenes/grid/grid_256.png",		# 고래
	"512": "res://scenes/grid/grid_512.png",		# 독수리
	"1024": "res://scenes/grid/grid_1024.png",	# 하마
	"2048": "res://scenes/grid/grid_2048.png",	# 곰
	"4096": "res://scenes/grid/grid_4096.png",	# 호랑이
	"8192": "res://scenes/grid/grid_8192.png",	# 코끼리
	"16384": "res://scenes/grid/grid_16384.png"	# 용
	}
var prelod_images: Dictionary = {}	# 이미지 경로 저장용 딕셔너리

##################################################
func _ready() -> void:
	for i in range(grid_size * grid_size):	# grid_size에 따라 grid를 0으로 초기화
		grid[i] = 0
	
	for key in image_paths.keys():	# image_paths에 따라 value 부분에 경로에 따른 이미지를 로드
		prelod_images[key] = ResourceLoader.load(image_paths[key])
		
	initial_grid_setting()	# 그리드 초기 설정
	draw_grid()	# 그리드 그리기
	check_score()	# 현재 score에 따른 best 값 수정
	
	hud.connect("reset_signal", Callable(self, "_on_reset_game"))	# reset_signal 수신 시 함수 실행
	
##################################################
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_up"):	# 입력에 따른 함수 실행
		move_grid("up")
	if Input.is_action_just_pressed("ui_down"):
		move_grid("down")
	if Input.is_action_just_pressed("ui_left"):
		move_grid("left")
	if Input.is_action_just_pressed("ui_right"):
		move_grid("right")

##################################################
func initial_grid_setting() -> void:
	randomize()	# 시드 초기화
	
	var first_index = randi_range(0, grid.size() - 1)	# 초기 두 index 값 설
	var second_index = randi_range(0, grid.size() - 1)
	
	while second_index == first_index:	# 두 번째 index가 첫 번째 index와 같으면 다를 때까지 재설정
		second_index = randi_range(0, grid.size() - 1)
		
	grid[first_index] = 2	# 각 grid에 초기 값인 2와 4 설정
	grid[second_index] = 4

##################################################
func get_grid_position(value: int) -> Vector2:	# 몇 번째 grid인지에 따라 좌표 반환
	var x = (value % grid_size) * 135
	var y = (value / grid_size) * 135 + top_margin
	return Vector2(x, y)

##################################################
func move_grid(value: String) -> void:
	var is_create: bool = false
	match value:
		"up":
			while true:	# 움직임이 없을 때까지 반복
				var repeat_check = false
				for index in range(4, grid.size()):	# 1행 제외
					if grid[index] != 0:	# 현재 값이 있는 grid만 확인
						var target_index = index - 4	#위에 있는 행을 확인
						if grid[target_index] == 0:	# 비어있으면
							grid[target_index] = grid[index]	# 이동
							grid[index] = 0
							repeat_check = true
							is_create = true
						elif grid[target_index] == grid[index]:	# 같은 값이면
							grid[target_index] = grid[target_index] * 2	#합체
							grid[index] = 0
							repeat_check = true
							is_create = true
				if repeat_check == false:
					break
		"down":
			while true:
				var repeat_check = false
				for index in range(11, -1, -1):	# 4행 제외, 아래부터 확인하며 역으로 반복
					if grid[index] != 0:
						var target_index = index + 4
						if grid[target_index] == 0:
							grid[target_index] = grid[index]
							grid[index] = 0
							repeat_check = true
							is_create = true
						elif grid[target_index] == grid[index]:
							grid[target_index] = grid[target_index] * 2
							grid[index] = 0
							repeat_check = true
							is_create = true
				if repeat_check == false:
					break
		"left":
			while true:
				var repeat_check = false
				for index in range(0, grid.size()):
					if index % 4 != 0 and grid[index] != 0:	# 1열 제외
						var target_index = index - 1
						if grid[target_index] == 0:
							grid[target_index] = grid[index]
							grid[index] = 0
							repeat_check = true
							is_create = true
						if grid[target_index] == grid[index]:
							grid[target_index] = grid[target_index] * 2
							grid[index] = 0
							repeat_check = true
							is_create = true
				if repeat_check == false:
					break
		"right":
			while true:
				var repeat_check = false
				for index in range(grid.size() - 1, -1, -1):	# 4열 제외
					if (index + 1) % 4 != 0 and grid[index] != 0:
						var target_index = index + 1
						if grid[target_index] == 0:
							grid[target_index] = grid[index]
							grid[index] = 0
							repeat_check = true
							is_create = true
						if grid[target_index] == grid[index]:
							grid[target_index] = grid[target_index] * 2
							grid[index] = 0
							repeat_check = true
							is_create = true
				if repeat_check == false:
					break
	
	if is_create == true:
		create_grid()	# 이동이나 합체가 모두 종료된 후 새로운 grid 하나 생성
		is_create = false
		move_audio_player.play()	# 이동 음향 재생
	else:
		error_audio_player.play()	#이동 불가 음향 재생

	draw_grid()
	GameManager.save_score()
	
##################################################
func draw_grid() -> void:	# prelod_images에 저장된 이미지 그리기
	for i in range(grid.size()):
		var key: String = str(grid[i])
		if key in prelod_images:
			var sprite = Sprite2D.new()
			sprite.texture = prelod_images[key]
			sprite.centered = false	#좌표 좌상단부터 그리기
			sprite.position = get_grid_position(i)
			add_child(sprite)
	check_score()
	
##################################################
func create_grid():
	var target_index: int = randi_range(0, grid.size() - 1)
	
	while grid[target_index] != 0:	# 비어있는 grid 찾기 위해 반복
		target_index = randi_range(0, grid.size() - 1)
	
	var randi_num: int = randi_range(0, 1)
	if randi_num == 0:	# 2와 4 중 하나 설정
		grid[target_index] = 2
	else:
		grid[target_index] = 4

##################################################
func check_score():
	for i in range(grid.size()):	# 모든 grid를 확인하여
		if grid[i] > GameManager.score:	#가장 높은 숫자인 grid를 찾고
			GameManager.set_score(grid[i])
		if GameManager.score > GameManager.best:	# best에 설정
			GameManager.set_best(GameManager.score)

##################################################
func _on_reset_game() -> void:	# 게임 초기화
	for i in range(grid_size * grid_size):
		grid[i] = 0
	
	for key in image_paths.keys():
		prelod_images[key] = ResourceLoader.load(image_paths[key])
		
	initial_grid_setting()
	draw_grid()
	check_score()
	GameManager.set_score(4)
