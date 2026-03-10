return {
	misc = {
		labels = {
			ma_stellar_seal = "Stellar Seal"
		}
	},
	descriptions = {
		Tarot = {
			c_ma_acecup = {
				name = "Ace of Cups",
				text = {
					"Creates a",
					"{C:attention}Boss Tag"
				}
			},
			c_ma_pagecup = {
				name = "Page of Cups",
				text = {
					"Gives {C:money}$#1#{} per {C:attention}Tag",
                    "received this run",
					"{C:inactive}(Max of {C:money}$#2#{C:inactive})",
                    "{C:inactive}(Currently {C:money}$#3#{C:inactive})"
				}
			},
			c_ma_knightcup = {
				name = "Knight of Cups",
				text = {
					"{C:green}#1# in #2#{} chance to create",
                    "a {C:attention}Foil{}, {C:attention}Holographic{}, or",
                    "{C:attention}Polychrome Tag"
				}
			},
			c_ma_queencup = {
				name = "Queen of Cups",
				text = {
					"Creates a {C:attention}Charm{},",
                    "{C:attention}Meteor{}, or {C:attention}Ethereal Tag{}"
				},
			},
			c_ma_kingcup = {
				name = "King of Cups",
				text = {
					"Creates a",
					"{C:attention}D6 Tag"
				},
			},
			c_ma_acepen = {
				name = "Ace of Pentacles",
				text = {
					"Gives {C:money}$#1#{} per all {C:blue}Common{},",
                    "{C:money}$#2#{} per all {C:green}Uncommon{}, {C:money}$#3#{} per all {C:red}Rare{},",
					"{C:money}$#4#{} per all {C:legendary,E:1}Legendary{} current Jokers",
					"{C:inactive}(Max of {C:money}$#5#{C:inactive})",
                    "{C:inactive}(Currently {C:money}$#6#{C:inactive})"
				},
			},
			c_ma_pagepen = {
				name = "Page of Pentacles",
				text = {
					"Gives {C:money}$#1#{} per round",
                    "in this run {C:inactive}(Max of {C:money}$#2#{C:inactive})",
                    "{C:inactive}(Currently {C:money}$#3#{C:inactive})"
				},
			},
			c_ma_knightpen = {
				name = "Knight of Pentacles",
				text = {
					"Creates a random",
                    "{C:attention}Money Tag"
				},
			},
			c_ma_queenpen = {
				name = "Queen of Pentacles",
				text = {
					"{C:green}#1# in #2#{} chance to create",
                    "a {C:attention}Coupon Tag"
				},
			},
			c_ma_kingpen = {
				name = "King of Pentacles",
				text = {
					"Creates a {C:dark_edition}Negative",
					"{C:dark_edition}Perishable Credit Card"
				},
			},
			c_ma_acewand = {
				name = "Ace of Wands",
				text = {
					"Enhances {C:attention}#1#",
					"selected cards"
				},
			},
			c_ma_pagewand = {
				name = "Page of Wands",
				text = {
					"{C:green}#1# in #2#{} chance to",
					"enhances {C:attention}#3#",
					"selected cards to {C:attention}Glass Card"
				},
			},
			c_ma_knightwand = {
				name = "Knight of Wands",
				text = {
					"Destroys {C:attention}#1#{} selected card",
					"Enhances adjacent cards to",
					"{C:attention}Stone Cards"
				},
			},
			c_ma_queenwand = {
				name = "Queen of Wands",
				text = {
					"Increases rank of {C:attention}#1#",
					"selected card and",
					"enhances into a {C:attention}Gold Card"
				},
			},
			c_ma_kingwand = {
				name = "King of Wands",
				text = {
					"Enhances {C:attention}#1#{} selected",
					"{C:attention}face{} cards to {C:attention}Steel Cards{}",
					"other selected cards to {C:attention}Wild Cards"
				},
			},
			
		},
		Other = {
			ma_stellar_seal = {
                name="Stellar Seal",
                text={
                    "Creates the {C:planet}Planet{} card",
                    "for final played {C:attention}poker hand{}",
                    "of round if {C:attention}held{} in hand",
					"{C:green}#1# in #2#{} chance to create",
					"{C:dark_edition}Negative{} copy of this planet",
                    "{C:inactive}(Must have room)"
                },
			}
		}
	}
}
