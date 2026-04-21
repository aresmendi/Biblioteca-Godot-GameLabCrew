# ==================================================
# SCRIPT: status_bar.gd
# TITLE: Control de barras de estado del mosquito
# AUTHOR: Davide F.
# DATE: 20-04-2026
# VERSION: 1.0
#
# DESCRIPTION:
# Este script se aplica a un CanvasLayer y gestiona
# la visualización de las barras de sangre y energía
# del mosquito dentro de la interfaz.
#
# Se encarga de localizar automáticamente los nodos
# necesarios, aplicar los colores configurados,
# actualizar el valor de relleno de cada barra y
# modificar sus dimensiones según el estado actual.
#
# Cuando el mosquito cambia de estado, el script
# adapta el tamaño visual de las barras para resaltar
# una de ellas sobre la otra.
# ==================================================
extends CanvasLayer

# ==================================================
# Referencias de nodos
# ==================================================
@export var margin_container: MarginContainer
@export var vbox_container: VBoxContainer

@export var bar_blood_background: ColorRect
@export var bar_blood_fill: ColorRect

@export var bar_energy_background: ColorRect
@export var bar_energy_fill: ColorRect

# ==================================================
# Valores
# ==================================================
@export_range(0.0, 1.0, 0.01) var blood_value: float = 0.30
@export_range(0.0, 1.0, 0.01) var energy_value: float = 0.75

# ==================================================
# Colores
# ==================================================
@export var blood_empty_color: Color = Color("601515")
@export var blood_fill_color: Color = Color("d91a1a")

@export var energy_empty_color: Color = Color("157cf0")
@export var energy_fill_color: Color = Color("badaff")

# ==================================================
# Tamaños
# ==================================================
@export var small_width: float = 180.0
@export var small_height: float = 16.0

@export var big_width: float = 350.0
@export var big_height: float = 22.0

# ==================================================
# Estado
# ==================================================
var mosquito_is_red: bool = false
var debug: bool = true

func _ready() -> void:
	if margin_container == null:
		margin_container = find_child("MarginContainer", true, false) as MarginContainer
	if vbox_container == null:
		vbox_container = find_child("VBoxContainer", true, false) as VBoxContainer

	if bar_blood_background == null:
		bar_blood_background = find_child("BarBloodBackground", true, false) as ColorRect
	if bar_blood_fill == null:
		bar_blood_fill = find_child("BarBloodFill", true, false) as ColorRect

	if bar_energy_background == null:
		bar_energy_background = find_child("BarEnergyBackground", true, false) as ColorRect
	if bar_energy_fill == null:
		bar_energy_fill = find_child("BarEnergyFill", true, false) as ColorRect

	if debug:
		assert(margin_container != null, "MarginContainer no encontrado")
		assert(vbox_container != null, "VBoxContainer no encontrado")
		assert(bar_blood_background != null, "BarBloodBackground no encontrado")
		assert(bar_blood_fill != null, "BarBloodFill no encontrado")
		assert(bar_energy_background != null, "BarEnergyBackground no encontrado")
		assert(bar_energy_fill != null, "BarEnergyFill no encontrado")

	_apply_colors()
	_refresh_bars()

func set_blood_value(value: float) -> void:
	blood_value = clamp(value, 0.0, 1.0)
	_refresh_bars()

func set_energy_value(value: float) -> void:
	energy_value = clamp(value, 0.0, 1.0)
	_refresh_bars()

func set_mosquito_state(is_red: bool) -> void:
	mosquito_is_red = is_red
	_refresh_bars()

func _apply_colors() -> void:
	bar_blood_background.color = blood_empty_color
	bar_blood_fill.color = blood_fill_color

	bar_energy_background.color = energy_empty_color
	bar_energy_fill.color = energy_fill_color

func _refresh_bars() -> void:
	if mosquito_is_red:
		_set_bar_size(bar_blood_background, big_width, big_height)
		_set_fill_size(bar_blood_background, bar_blood_fill, blood_value)

		_set_bar_size(bar_energy_background, small_width, small_height)
		_set_fill_size(bar_energy_background, bar_energy_fill, energy_value)
	else:
		_set_bar_size(bar_blood_background, small_width, small_height)
		_set_fill_size(bar_blood_background, bar_blood_fill, blood_value)

		_set_bar_size(bar_energy_background, big_width, big_height)
		_set_fill_size(bar_energy_background, bar_energy_fill, energy_value)

func _set_bar_size(background: ColorRect, width: float, height: float) -> void:
	background.custom_minimum_size = Vector2(width, height)
	background.size = Vector2(width, height)

func _set_fill_size(background: ColorRect, fill: ColorRect, value: float) -> void:
	var fill_width: float = background.custom_minimum_size.x * value
	var fill_height: float = background.custom_minimum_size.y

	fill.position = Vector2.ZERO
	fill.custom_minimum_size = Vector2(fill_width, fill_height)
	fill.size = Vector2(fill_width, fill_height)
