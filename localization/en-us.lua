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
			c_ma_acesword = {
				name = "Ace of Swords",
				text = {
					"Creates {C:attention}#1#{} {C:planet}Planet{} cards",
					"of your least played",
					"{C:attention}Poker Hand{}",
                    "{C:inactive}(Must have room)"
				},
			},
			c_ma_pagesword = {
				name = "Page of Swords",
				text = {
					"Destroys {C:attention}#1#{} selected card",
                    "Creates {C:planet}Planet{} card",
					"of your most played",
					"{C:attention}Poker Hand{}",
                    "{C:inactive}(Must have room)"
				},
			},
			c_ma_knightsword = {
				name = "Knight of Swords",
				text = {
					"Creates last sold",
					"{C:planet}Planet{} card",
					"{C:green}#1# in #2#{} chance to",
					"create another one",
                    "{C:inactive}(Must have room)"
				},
			},
			c_ma_queensword = {
				name = "Queen of Swords",
				text = {
					"Creates a {C:dark_edition}Negative",
					"{C:dark_edition}Perishable Space Joker",
					"{C:green}#1# in #2#{} chance to",
					"downgrade a random {C:attention}Poker Hand{}",
					"by {C:attention}#3#{} levels"
				},
			},
			c_ma_kingsword = {
				name = "King of Swords",
				text = {
					"{C:green}#1# in #2#{} chance to",
					"create a {C:spectral}Black Hole",
					"{C:green}#1# in #3#{} chance to",
					"create {C:dark_edition}Negative{} copy",
                    "{C:inactive}(Must have room)"
				},
			}
			
		},
		Spectral = {
			c_ma_cup = {
				name = "Cup",
				text = {
					"Creates #1# random {C:attention}tags",
					"Destroys all {C:attention}consumables"
				},
                unlock={
                    "Discover every",
					"tarot card suit {E:1,C:tarot}Cups"
                }
			},
			c_ma_pentacle = {
				name = "Pentacle",
				text = {
					"Sets money to {C:money}$0",
					"Gives {C:money}$#1#{} per your {C:attention}Voucher",
                    "Gives {C:money}$#2#{} for each",
					"level of your {C:attention}Poker Hand"
				},
                unlock={
                    "Discover every",
					"tarot card suit {E:1,C:tarot}Pentacles"
                }
			},
			c_ma_wand = {
				name = "Wand",
				text = {
					"Cards in hand",
					"gain the {C:attention}enhancement{} of",
					"{C:attention}1{} selected card",
					"{C:green}#1# in #2#{} chance to",
					"destroy a card in hand"
				},
                unlock={
                    "Discover every",
					"tarot card suit {E:1,C:tarot}Wands"
                }
			},
			c_ma_sword = {
				name = "Sword",
				text = {
					"Downgrade all {C:attention}Poker Hands{} by {C:attention}#1#{} level",
					"Adds a {C:blue}Blue Seal{} to selected card",
					"and adjacent cards",
					"If selected card already has a {C:blue}Blue Seal{},",
					"upgrade it to a {C:blue}Stellar Seal{}"
				},
                unlock={
                    "Discover every",
					"tarot card suit {E:1,C:tarot}Swords"
                }
			}
		},
		Other = {
			ma_stellar_seal = {
                name="Stellar Seal",
                text={
                    "Creates the {C:planet}Planet{} card",
                    "for final played {C:attention}Poker Hand{}",
                    "of round if {C:attention}held{} in hand",
					"{C:green}#1# in #2#{} chance to create",
					"{C:dark_edition}Negative{} copy of this {C:planet}planet",
                    "{C:inactive}(Must have room)"
                },
			}
		}
	}
}
