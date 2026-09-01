extends Control

const ProfileSnapshot = preload("res://scripts/profile/profile_snapshot.gd")
const UiTokens = preload("res://scripts/config/ui_tokens.gd")
const ScenePaths = preload("res://scripts/config/scene_paths.gd")
const PressScaleUtil = preload("res://scripts/ui/press_scale.gd")

@onready var title_label: Label = %TitleLabel
@onready var avatar_texture: TextureRect = %AvatarTexture
@onready var pseudo_label: Label = %PseudoLabel
@onready var pseudo_input: LineEdit = %PseudoInput
@onready var level_label: Label = %LevelLabel
@onready var games_value_label: Label = %GamesValueLabel
@onready var wins_value_label: Label = %WinsValueLabel
@onready var losses_value_label: Label = %LossesValueLabel
@onready var win_rate_value_label: Label = %WinRateValueLabel
@onready var favorite_value_label: Label = %FavoriteValueLabel
@onready var games_caption_label: Label = %GamesCaptionLabel
@onready var wins_caption_label: Label = %WinsCaptionLabel
@onready var losses_caption_label: Label = %LossesCaptionLabel
@onready var win_rate_caption_label: Label = %WinRateCaptionLabel
@onready var favorite_caption_label: Label = %FavoriteCaptionLabel
@onready var change_photo_button: Button = %ChangePhotoButton
@onready var remove_photo_button: Button = %RemovePhotoButton
@onready var save_button: Button = %SaveButton
@onready var back_button: Button = %BackButton
@onready var status_label: Label = %StatusLabel
@onready var photo_dialog: FileDialog = %PhotoDialog


func _ready() -> void:
	pseudo_input.max_length = UiTokens.MAX_PLAYER_NAME_LENGTH
	_apply_translations()
	_refresh_profile()
	back_button.pressed.connect(_on_back_pressed)
	change_photo_button.pressed.connect(_on_change_photo_pressed)
	remove_photo_button.pressed.connect(_on_remove_photo_pressed)
	save_button.pressed.connect(_on_save_pressed)
	photo_dialog.files_selected.connect(_on_photo_selected)
	LocaleManager.locale_changed.connect(_on_locale_changed)
	PressScaleUtil.wire(back_button, self)
	PressScaleUtil.wire(change_photo_button, self)
	PressScaleUtil.wire(remove_photo_button, self)
	PressScaleUtil.wire(save_button, self)


func _apply_translations() -> void:
	title_label.text = tr("UI_PROFILE_TITLE")
	pseudo_label.text = tr("UI_PROFILE_PSEUDO")
	pseudo_input.placeholder_text = tr("UI_PROFILE_PSEUDO_PLACEHOLDER")
	games_caption_label.text = tr("UI_PROFILE_GAMES_PLAYED")
	wins_caption_label.text = tr("UI_PROFILE_WINS")
	losses_caption_label.text = tr("UI_PROFILE_LOSSES")
	win_rate_caption_label.text = tr("UI_PROFILE_WIN_RATE")
	favorite_caption_label.text = tr("UI_PROFILE_FAVORITE_THEME")
	change_photo_button.text = tr("UI_PROFILE_CHANGE_PHOTO")
	remove_photo_button.text = tr("UI_PROFILE_REMOVE_PHOTO")
	save_button.text = tr("UI_PROFILE_SAVE")
	back_button.text = tr("UI_BACK")
	status_label.text = ""


func _refresh_profile() -> void:
	var profile: Dictionary = ProfileSnapshot.build(LocaleManager.get_content_locale())
	pseudo_input.text = profile.get("player_name", UiTokens.DEFAULT_PLAYER_NAME)
	level_label.text = tr("UI_PLAYER_LEVEL").format({"level": profile.get("level", 1)})
	avatar_texture.texture = profile.get("avatar_texture")
	remove_photo_button.visible = profile.get("has_custom_avatar", false)

	games_value_label.text = str(profile.get("games_played", 0))
	wins_value_label.text = str(profile.get("wins", 0))
	losses_value_label.text = str(profile.get("losses", 0))
	win_rate_value_label.text = "%.0f%%" % profile.get("win_rate_percent", 0.0)

	var favorite_name: String = profile.get("favorite_category_name", "")
	if favorite_name.is_empty():
		favorite_value_label.text = tr("UI_PROFILE_NO_FAVORITE")
	else:
		favorite_value_label.text = favorite_name


func _on_change_photo_pressed() -> void:
	photo_dialog.popup_centered_ratio(0.8)


func _on_remove_photo_pressed() -> void:
	SaveManager.clear_profile_avatar()
	status_label.text = ""
	_refresh_profile()


func _on_photo_selected(paths: PackedStringArray) -> void:
	if paths.is_empty():
		return
	if SaveManager.set_profile_avatar_from_file(paths[0]):
		status_label.text = ""
		_refresh_profile()
	else:
		status_label.text = tr("UI_WRONG")


func _on_save_pressed() -> void:
	SaveManager.set_player_name(pseudo_input.text)
	status_label.text = tr("UI_PROFILE_SAVED")
	_refresh_profile()


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(ScenePaths.MAIN_MENU)


func _on_locale_changed(_locale: String) -> void:
	_apply_translations()
	_refresh_profile()
