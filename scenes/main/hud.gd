extends CanvasLayer

##################################################
signal reset_signal	# 게임 초기화 신호

##################################################
@onready var best_label: Label = $VBoxContainer/BestMarginContainer/Best		# 최고 점수 라벨
@onready var score_label: Label = $VBoxContainer/ScoreMarginContainer2/Score	# 현재 점수 라벨
@onready var reset_button: TextureButton = $MarginContainer/TextureButton		# 초기화 버튼

##################################################
func _ready() -> void:
	reset_button.connect("button_up", Callable(self, 
	"_on_reset_button_released"))	# 초기화 버튼 클릭(up) 시 함수 실행

##################################################
func _process(delta: float) -> void:
	update_labels()	# 점수 라벨 업데이트

##################################################
func update_labels() -> void:
	best_label.text = "BEST :" + str(GameManager.best).pad_zeros(5)		# 최고 점수 라벨 업데이트
	score_label.text = "SCORE:" + str(GameManager.score).pad_zeros(5)	# 현재 점수 라벨 업데이트

##################################################
func _on_reset_button_released() -> void:
		emit_signal("reset_signal")	# 초기화 신호 발생
