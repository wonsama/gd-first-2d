extends Area2D

export var speed = 400 # 플레이어가 이동하는 속도(픽셀/초)

var screen_size # 게임 창의 크기입니다.

signal hit

# _ready()함수는 노드가 장면 트리에 들어갈 때 호출되며, 게임 창의 크기를 찾기에 좋은 시간입니다.
func _ready():
	screen_size = get_viewport_rect().size
	hide()

# _process()함수를 사용하여 플레이어가 수행할 작업을 정의할 수 있습니다. 
# _process()프레임마다 호출되므로 자주 변경될 것으로 예상되는 게임의 요소를 업데이트하는 데 사용할 것입니다. 
func _process(delta):
	var velocity = Vector2.ZERO # 플레이어의 움직임 벡터
	
	# 키를 눌렀는지 여부를 감지할 Input.is_action_pressed()
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	
	# 각 입력을 확인하고 에서 더하거나 빼서 전체 방향을 얻어야 됨
	# 예를 들어 와 를 동시에 누르고 있으면 결과 벡터는 . 
	# 이 경우 수평 및 수직 이동을 추가하기 때문에 플레이어는 수평으로 이동할 때보다 대각선 으로 더 빠르게 이동
	# 속도 를 정규화(normalized) 하면 길이 를 로 설정 1한 다음 원하는 속도를 곱하는 것을 방지
	
	# $노드명 은 get_node(노드명) 과 기능이 동일함.
	# 현재 노드 또는 자식노드만 탐색 가능함.
	if velocity.length() > 0: # 키 입력이 감지되면 
		velocity = velocity.normalized() * speed
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()

	position += velocity * delta
	
	# clamp (집게) 화면 영역 이탈을 방지함. 바운더리 설정하는 것이라 생각하면 될 듯
	position.x = clamp(position.x, 0 + 25, screen_size.x - 25)
	position.y = clamp(position.y, 0 + 35, screen_size.y - 35)
	 
	# 이동 방향에 따른 에니메이션 스프라이트 변경 및 반전 처리
	if velocity.x != 0:
		$AnimatedSprite.animation = "walk"
		$AnimatedSprite.flip_v = false
		$AnimatedSprite.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite.animation = "up"
		$AnimatedSprite.flip_v = velocity.y > 0

func _on_Player_body_entered(body):
	hide() # 공격당한 후 플레이어가 사라집니다.
	emit_signal("hit")
	# 적이 플레이어를 칠 때마다 신호가 방출됩니다. 
	# hit신호를 두 번 이상 트리거하지 않도록 플레이어의 충돌을 비활성화
	# 영역의 충돌 모양을 비활성화하면 엔진의 충돌 처리 도중에 발생할 경우 오류가 발생할 수 있습니다. 
	# 사용 set_deferred()은 안전할 때까지 모양을 비활성화할 때까지 기다리라고 Godot에 지시
	# => 요약
	# $CollisionShape2D.disabled = true 하면 물리 엔진 작업 처리 시 오류 발생 될 수 있어
	# set_deferred 를 통해 지연 처리 하도록 함.
	$CollisionShape2D.set_deferred("disabled", true)
	


func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
