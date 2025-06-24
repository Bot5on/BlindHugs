extends Node2D

# Система визуальных эффектов для отображения волн и следов от движения игрока
# Создает расширяющиеся волны и спрайты следов с настраиваемыми параметрами

# Константы для настройки волновых эффектов
const WAVE_LIFETIME: float = 2.0        # Продолжительность жизни волны в секундах
const WAVE_MAX_RADIUS: float = 200.0    # Максимальный радиус расширения волны
const WAVE_WIDTH: float = 2.0           # Толщина линии волны в пикселях
const WAVE_POINTS: int = 100            # Количество точек для создания плавного круга

# Константы для настройки следов
const FOOTSTEP_LIFETIME: float = 1.2    # Время отображения следа на экране
const FOOTSTEP_SPRITE_SCALE: float = 0.03 # Коэффициент масштабирования спрайта следа

# Константы для визуальных эффектов
const FADE_SMOOTHING: float = 5.0       # Плавность затухания альфа-канала
const GLOW_INTENSITY: float = 0.3       # Интенсивность эффекта свечения
const PULSE_FREQUENCY: float = 4.0      # Частота пульсации волны (колебаний в секунду)

# Предзагрузка сцены для создания следов
const FootprintScene = preload("res://scenes/Footprint.tscn")

# Класс для хранения данных об отдельном волновом эффекте
class WaveEffect:
	var position: Vector2   # Позиция центра волны
	var direction: Vector2  # Направление движения для ориентации эффекта
	var time: float = 0.0   # Время существования эффекта
	var color: Color        # Цвет волны

# Массив всех активных волновых эффектов
var effects: Array[WaveEffect] = []

# Массив тел игроков для исключения из физических запросов
var player_bodies: Array = []

# Переключатель для чередования левой и правой ноги при создании следов
var is_left_foot_next: bool = true

# Создание нового эффекта волны и следа
# pos - позиция создания эффекта
# color - цвет эффекта
# p_direction - направление движения для ориентации следа
func create_effect(pos: Vector2, color: Color, p_direction: Vector2):
	# Создаем новый волновой эффект
	var effect = WaveEffect.new()
	effect.position = pos
	effect.color = color
	effect.direction = p_direction
	effects.append(effect)
	
	# Создаем спрайт следа в указанной позиции
	_create_footprint_sprite(pos, color, p_direction)

# Основной цикл обновления эффектов
func _process(delta: float):
	# Обновляем время жизни всех эффектов и удаляем устаревшие
	# Проходим в обратном порядке, чтобы безопасно удалять элементы
	for i in range(effects.size() - 1, -1, -1):
		effects[i].time += delta
		
		# Удаляем эффект, если его время жизни истекло
		if effects[i].time > WAVE_LIFETIME:
			effects.remove_at(i)
	
	# Запрашиваем перерисовку для обновления визуала
	queue_redraw()

# Функция отрисовки всех визуальных эффектов
func _draw():
	# Отрисовываем каждую активную волну
	for effect in effects:
		_draw_wave(effect)

# Создание и настройка спрайта следа
# pos - позиция следа
# color - цвет следа
# direction - направление для поворота спрайта
func _create_footprint_sprite(pos: Vector2, color: Color, direction: Vector2):
	# Создаем экземпляр сцены следа
	var footprint = FootprintScene.instantiate()
	add_child(footprint)
	
	# Устанавливаем позицию следа
	footprint.global_position = pos
	
	# Вычисляем угол поворота на основе направления движения
	# Добавляем 90 градусов для корректной ориентации спрайта
	var rot_degrees = direction.angle() * (180 / PI) + 90
	
	# Настраиваем след через его метод setup
	footprint.setup(color, FOOTSTEP_LIFETIME, rot_degrees)
	
	# Применяем масштабирование к спрайту
	footprint.get_node("Sprite2D").scale = Vector2(FOOTSTEP_SPRITE_SCALE, FOOTSTEP_SPRITE_SCALE)
	
	# Отзеркаливаем спрайт для правой ноги
	if not is_left_foot_next:
		footprint.get_node("Sprite2D").scale.x *= -1
	
	# Переключаем ногу для следующего шага
	is_left_foot_next = not is_left_foot_next

# Отрисовка отдельной расширяющейся волны
# effect - данные волнового эффекта
func _draw_wave(effect: WaveEffect):
	# Вычисляем прогресс анимации от 0 до 1
	var progress: float = effect.time / WAVE_LIFETIME
	
	# Пропускаем отрисовку завершенных эффектов
	if progress >= 1.0:
		return
	
	# Используем кубическую интерполяцию для плавного расширения
	var radius_progress: float = 1.0 - pow(1.0 - progress, 3.0)
	var current_radius: float = WAVE_MAX_RADIUS * radius_progress
	
	# Создаем эффект пульсации волны
	var pulse: float = 1.0 + sin(effect.time * PULSE_FREQUENCY) * 0.1
	
	# Вычисляем прозрачность с учетом затухания и пульсации
	var alpha: float = pow(1.0 - progress, FADE_SMOOTHING) * pulse
	var main_color: Color = Color(effect.color, alpha)
	
	# Рисуем основную волну
	_draw_wave_polyline(effect.position, current_radius, main_color, WAVE_WIDTH)
	
	# Рисуем эффект свечения с большей толщиной и меньшей прозрачностью
	var glow_color: Color = Color(effect.color, alpha * GLOW_INTENSITY)
	_draw_wave_polyline(effect.position, current_radius, glow_color, WAVE_WIDTH * 3.0)

# Отрисовка волны в виде полилинии с физическими препятствиями
# center - центр волны
# radius - текущий радиус волны
# color - цвет линии
# width - толщина линии
func _draw_wave_polyline(center: Vector2, radius: float, color: Color, width: float):
	var points = PackedVector2Array()
	var space_state = get_world_2d().direct_space_state
	
	# Создаем точки окружности с проверкой коллизий
	for i in range(WAVE_POINTS + 1):
		# Вычисляем угол текущей точки
		var angle: float = i * TAU / WAVE_POINTS
		var direction: Vector2 = Vector2.from_angle(angle)
		var target_pos: Vector2 = center + direction * radius
		
		# Создаем луч от центра к целевой позиции
		var query = PhysicsRayQueryParameters2D.create(center, target_pos)
		
		# Исключаем тела игроков из проверки коллизий
		if not player_bodies.is_empty():
			query.exclude = player_bodies.map(func(p): return p.get_rid())
		
		# Выполняем проверку пересечения луча с препятствиями
		var result = space_state.intersect_ray(query)
		
		# Используем точку пересечения или целевую позицию, если препятствий нет
		points.append(result.position if result else target_pos)
	
	# Рисуем полилинию, если есть достаточно точек
	if points.size() > 1:
		draw_polyline(points, color, width, true)

# Публичный метод для установки массива игроков, которые будут исключены из физических запросов
# players_array - массив тел игроков
func set_players(players_array: Array):
	player_bodies = players_array
