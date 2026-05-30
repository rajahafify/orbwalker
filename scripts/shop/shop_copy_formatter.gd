extends RefCounted
class_name ShopCopyFormatter


static func price_text(price: int, sold_out: bool, _affordable: bool, treasure_chest_pending: bool) -> String:
	if sold_out:
		return "SOLD OUT"
	if treasure_chest_pending:
		return "WAIT CHEST"
	return "$%d" % price


static func shop_card_description(offer: Dictionary) -> String:
	var content_id := String(offer.get("content_id", "")).to_lower()
	var offer_type := String(offer.get("type", "")).to_lower()
	var display_name := String(offer.get("display_name", "Offer"))
	var description := String(offer.get("description", ""))
	var amount := _first_signed_amount(description, 1)
	if content_id.begins_with("shortsword"):
		return "+%d Attack" % amount
	if content_id.begins_with("buckler"):
		return "Gain +%d Armor\neach turn" % amount
	if content_id.begins_with("coin_purse"):
		return "Gain +%d Gold\non Gold matches" % amount
	if content_id.begins_with("healing_charm"):
		return "Heal +%d more\non Hearts" % amount
	if content_id.begins_with("leather_gloves"):
		return "+%d Combo count\nfor damage" % amount
	if offer_type == "mastery_card" or content_id.ends_with("_mastery"):
		return "+%d %s\nMastery" % [_mastery_amount(description), _mastery_element_name(display_name, content_id)]
	if offer_type == "treasure_chest":
		if content_id.find("fire") >= 0:
			return "Choose 1 of 3\nFire rewards"
		if content_id.find("earth") >= 0:
			return "Choose 1 of 3\nEarth rewards"
		if content_id.find("shadow") >= 0:
			return "Choose 1 of 3\nShadow rewards"
		if content_id.find("elemental") >= 0:
			return "Choose 1 of 3\nElement rewards"
		return "Choose 1 of 3\nrewards"
	if offer_type == "consumable":
		return _compact_consumable_description(display_name, description)
	return description


static func shop_relic_description(relic_offer: Dictionary) -> String:
	var content_id := String(relic_offer.get("content_id", "")).to_lower()
	var description := String(relic_offer.get("description", ""))
	if content_id == "deep_pockets":
		return "Gold value +2\n+2 bonus Gold"
	if content_id == "stalwart_mantle":
		return "Gain +6 Armor\nat turn start"
	if content_id == "golden_idol":
		return "Combo multiplier x1.20\n+2 bonus Gold"
	if content_id == "crown_of_chains":
		return "Combo count +3\n+5 Attack each turn"
	if content_id == "merchant_compass":
		return "+1 bonus Gold\n+2 Healing on Hearts"
	return _wrap_relic_copy(description)


static func relic_title_color(rarity: String) -> Color:
	match rarity.to_lower():
		"uncommon":
			return Color(0.52, 0.88, 1.0, 1.0)
		"rare":
			return Color(0.92, 0.58, 1.0, 1.0)
		"epic":
			return Color(1.0, 0.52, 1.0, 1.0)
		_:
			return Color(1.0, 0.82, 0.48, 1.0)


static func _compact_consumable_description(display_name: String, description: String) -> String:
	var amount := _first_signed_amount(description, 3)
	var clean_name := display_name.replace(" Scroll", "")
	if description.findn("Convert") >= 0:
		return "Convert %d non-%s\norbs to %s orbs" % [amount, clean_name, clean_name]
	return description


static func _wrap_relic_copy(value: String) -> String:
	var lines: Array[String] = []
	for raw_segment in value.strip_edges().split("\n", false):
		var words := String(raw_segment).strip_edges().split(" ", false)
		var current := ""
		for word_value in words:
			var word := String(word_value)
			var candidate := word if current == "" else "%s %s" % [current, word]
			if candidate.length() > 26 and current != "":
				lines.append(current)
				current = word
			else:
				current = candidate
		if current != "":
			lines.append(current)
	return "\n".join(lines.slice(0, 2))


static func _mastery_element_name(display_name: String, content_id: String) -> String:
	var clean_display := display_name.replace(" Mastery", "").strip_edges()
	if clean_display != "":
		return clean_display
	var clean_id := content_id.replace("_mastery", "").replace("_", " ").strip_edges()
	return clean_id.capitalize()


static func _mastery_amount(description: String) -> int:
	var regex := RegEx.new()
	if regex.compile("\\bby\\s+(\\d+)") != OK:
		return 1
	var result := regex.search(description)
	if result == null:
		return 1
	return maxi(1, int(result.get_string(1)))


static func _first_signed_amount(description: String, default_value: int) -> int:
	var regex := RegEx.new()
	if regex.compile("\\+(\\d+)") != OK:
		return default_value
	var result := regex.search(description)
	if result == null:
		return default_value
	return maxi(1, int(result.get_string(1)))
