extends Node2D

# Получаем ссылку на наш спрайт, чтобы не искать его каждый раз
@onready var sprite: Sprite2D = $Sprite2D

var lifetime: float = 1.0
var life_remaining: float = 1.0

# Эта функция будет вызываться, чтобы настроить след
func setup(p_color: Color, p_lifetime: float, p_rotation_degrees: float):
	lifetime = p_lifetime
	life_remaining = p_lifetime
	
	sprite.modulate = p_color
	rotation_degrees = p_rotation_degrees

# Эта функция вызывается каждый кадр и отвечает за "жизнь" следа
func _process(delta: float):
	# Уменьшаем оставшееся время жизни
	life_remaining -= delta
	
	# Если жизнь кончилась, удаляем узел из сцены
	if life_remaining <= 0:
		queue_free()
		return
		
	# Обновляем прозрачность спрайта на основе оставшейся жизни
	var life_ratio = life_remaining / lifetime
	# Делаем затухание более резким в конце
	sprite.modulate.a = life_ratio * life_ratio 
