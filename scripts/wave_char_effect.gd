class_name WaveCharEffect extends RichTextEffect

# Указываем BBCode-тег для нашего эффекта
var bbcode = "wave"

func _process_custom_fx(char_fx: CharFXTransform):
	# Параметры для настройки волны
	var speed = 5.0      # Скорость волны
	var frequency = 2.5  # Частота (расстояние между "пиками" волны)
	var amplitude = 8.0  # Высота "прыжка" буквы
	
	# Получаем время, прошедшее с начала отображения текста
	var time = char_fx.elapsed_time
	
	# Получаем индекс (порядковый номер) символа
	var index = char_fx.index
	
	# Вычисляем смещение по оси Y с помощью синусоиды
	# time * speed - заставляет волну двигаться
	# index / frequency - создает сдвиг фазы для каждой буквы, формируя волну
	var y_offset = sin(time * speed + index / frequency) * amplitude
	
	# Применяем смещение к текущему символу
	char_fx.offset.y = y_offset
	
	return true
