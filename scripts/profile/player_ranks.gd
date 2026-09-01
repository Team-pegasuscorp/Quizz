class_name PlayerRanks
extends RefCounted


static func title_for_level(level: int) -> String:
	if level >= 25:
		return "UI_RANK_LEGEND"
	if level >= 15:
		return "UI_RANK_MASTER"
	if level >= 10:
		return "UI_RANK_EXPERT"
	if level >= 5:
		return "UI_RANK_CHALLENGER"
	if level >= 2:
		return "UI_RANK_APPRENTICE"
	return "UI_RANK_ROOKIE"
