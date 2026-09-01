class_name ScenePaths
extends RefCounted

enum Tab { HOME, QUIZ, MULTIPLAYER, LEADERBOARD, PROFILE }

const TAB_COUNT := 5
## Swipe / bottom-nav page order — Quiz centered (index 2).
const TAB_PAGE_ORDER: Array[int] = [
	Tab.HOME,
	Tab.MULTIPLAYER,
	Tab.QUIZ,
	Tab.LEADERBOARD,
	Tab.PROFILE,
]
const APP_SHELL := "res://scenes/app_shell.tscn"
const CATEGORY_SELECT := "res://scenes/category_select.tscn"
const QUIZ_GAME := "res://scenes/game/quiz_game.tscn"
const RESULTS := "res://scenes/results/results_screen.tscn"


static func go_to_shell(tree: SceneTree, tab: Tab = Tab.HOME) -> void:
	GameManager.shell_tab_index = tab
	tree.change_scene_to_file(APP_SHELL)


static func page_index_for_tab(tab: Tab) -> int:
	var index := TAB_PAGE_ORDER.find(tab)
	return index if index >= 0 else 0


static func tab_for_page_index(page: int) -> Tab:
	page = clampi(page, 0, TAB_PAGE_ORDER.size() - 1)
	return TAB_PAGE_ORDER[page] as Tab
