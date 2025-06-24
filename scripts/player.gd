extends CharacterBody2D

signal step_taken(position, color, direction)

# --- Настройки Игрока  ---
@export var speed: float = 150.0
@export var player_id: int = 1
@export var ray_color: Color = Color.CYAN

# --- Внутренние переменные ---
var step_timer: float = 0.0
const STEP_INTERVAL: float = 0.2 # Интервал между шагами в секундах


# Вызывается каждый физический кадр
func _physics_process(delta: float):
	# Увеличиваем таймер с последнего шага
	step_timer += delta

	# Определяем направление движения на основе ID игрока
	var direction: Vector2
	if player_id == 1:
		direction = Input.get_vector("p1_left", "p1_right", "p1_up", "p1_down")
	else:
		direction = Input.get_vector("p2_left", "p2_right", "p2_up", "p2_down")

	# Двигаем персонажа
	velocity = direction.normalized() * speed
	move_and_slide()

	# Если персонаж движется и прошло достаточно времени с последнего шага
	if velocity.length() > 0 and step_timer >= STEP_INTERVAL:
		step_timer = 0.0 # Сбрасываем таймер
		# Отправляем 'velocity' как третий аргумент сигнала
		step_taken.emit(global_position, ray_color, velocity)
