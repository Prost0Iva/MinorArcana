return {
	misc = {
		labels = {
			ma_stellar_seal = "Звездная печать"
		}
	},
	descriptions = {
		Tarot = {
			c_ma_acecup = {
				name = "Туз кубков",
				text = {
					"Создает",
					"{C:attention}Тег босса"
				},
			},
			c_ma_pagecup = {
				name = "Паж кубков",
				text = {
					"Дает {C:money}$#1#{} за каждый {C:attention}тег",
                    "полученный в этой партии",
					"{C:inactive}(макс. {C:money}$#2#{C:inactive})",
                    "{C:inactive}(сейчас {C:money}$#3#{C:inactive})"
				},
			},
			c_ma_knightcup = {
				name = "Рыцарь кубков",
				text = {
					"Шанс {C:green}#1# из #2#{} создать",
                    "{C:attention}Фольговый{}, {C:attention}Голографический{},",
                    "или {C:attention}Полихромный тег"
				},
			},
			c_ma_queencup = {
				name = "Королева кубков",
				text = {
					"Создает {C:attention}Тег очарования{},",
                    "{C:attention}Тег метеора{}, или {C:attention}Эфирный тег{}"
				},
			},
			c_ma_kingcup = {
				name = "Король кубков",
				text = {
					"Создает",
					"{C:attention}Тег D6"
				},
			},
			c_ma_acepen = {
				name = "Туз пентаклей",
				text = {
					"Дает {C:money}$#1#{} за каждого {C:blue}Обычного{},",
                    "{C:money}$#2#{} за каждого {C:green}Необычного{}, {C:money}$#3#{} за каждого {C:red}Редкого{},",
					"{C:money}$#4#{} за каждого {C:legendary,E:1}Легендарного{} текущего джокера",
					"{C:inactive}(макс. {C:money}$#5#{C:inactive})",
                    "{C:inactive}(сейчас {C:money}$#6#{C:inactive})"
				},
			},
			c_ma_pagepen = {
				name = "Паж пентаклей",
				text = {
					"Дает {C:money}$#1#{} за каждый раунд",
                    "этой партии {C:inactive}(макс. {C:money}$#2#{C:inactive})",
                    "{C:inactive}(сейчас {C:money}$#3#{C:inactive})"
				},
			},
			c_ma_knightpen = {
				name = "Рыцарь пентаклей",
				text = {
					"Создает случайный",
                    "{C:attention}денежный тег"
				},
			},
			c_ma_queenpen = {
				name = "Королева пентаклей",
				text = {
					"Шанс {C:green}#1# из #2#{} создать",
                    "{C:attention}Тег купона"
				},
			},
			c_ma_kingpen = {
				name = "Король пентаклей",
				text = {
					"Создает {C:dark_edition}Негативную",
					"{C:dark_edition}Портящуюся кредитную карту"
				},
			},
			c_ma_acewand = {
				name = "Туз жезлов",
				text = {
					"Улучшает до {C:attention}#1#",
					"выбранных карт"
				},
			},
			c_ma_pagewand = {
				name = "Паж жезлов",
				text = {
					"{C:green}#1# из #2#{} шанс",
					"улучшить до {C:attention}#3#",
					"выбранных карт до {C:attention}Стеклянной карты"
				},
			},
			c_ma_knightwand = {
				name = "Рыцарь жезлов",
				text = {
					"Унничтожает {C:attention}#1#{} выбранную карту",
					"Улучшает соседние карты до",
					"{C:attention}Каменной карты"
				},
			},
			c_ma_queenwand = {
				name = "Королева жезлов",
				text = {
					"Увеличивает достоинство {C:attention}#1#",
					"выбранной карты и",
					"улучшает её до {C:attention}Золотой карты"
				},
			},
			c_ma_kingwand = {
				name = "Король жезлов",
				text = {
					"Улучшает {C:attention}#1#{} выбранные",
					"карты с {C:attention}лицом{} до {C:attention}Стальной карты{}",
					"другие выбранные карты до {C:attention}Дикой карты"
				},
			},
			c_ma_acesword = {
				name = "Туз мечей",
				text = {
					"Создает {C:attention}#1#{} карты {C:planet}планеты{}",
					"вашей наименее часто играемой",
					"{C:attention}покерной руки{}",
                    "{C:inactive}(Должно быть место)"
				},
			},
			c_ma_pagesword = {
				name = "Паж мечей",
				text = {
					"Уничтожает {C:attention}#1#{} выбранную карту",
                    "Создает карту {C:planet}планеты{}",
					"наиболее играемой",
					"{C:attention}покерной руки{}",
                    "{C:inactive}(Должно быть место)"
				},
			},
			c_ma_knightsword = {
				name = "Рыцарь мечей",
				text = {
					"Создает последнюю",
					"проданную карту {C:planet}планеты{}",
					"{C:green}#1# из #2#{} шанс создать",
					"ещё одну",
                    "{C:inactive}(Должно быть место)"
				},
			},
			c_ma_queensword = {
				name = "Королева мечей",
				text = {
					"Создает {C:dark_edition}Негативного",
					"{C:dark_edition}временного космического джокера",
					"{C:green}#1# из #2#{} шанс",
					"понизить уровень случайной {C:attention}покерной руки{}",
					"на {C:attention}#3#{} уровня"
				},
			},
			c_ma_kingsword = {
				name = "Король мечей",
				text = {
					"{C:green}#1# из #2#{} шанс",
					"создать {C:spectral}Черную дыру",
					"{C:green}#1# из #3#{} шанс",
					"создать её {C:dark_edition}негативную{} копию",
                    "{C:inactive}(Должно быть место)"
				},
			}
		},
		Spectral = {
			c_ma_cup = {
				name = "Кубок",
				text = {
					"Создает #1# случайных {C:attention}тега",
					"Уничтожает все {C:attention}расходники"
				},
                unlock={
                    "Открыть каждую карту",
					"таро масти {E:1,C:tarot}Кубки"
                }
			},
			c_ma_pentacle = {
				name = "Пентакль",
				text = {
					"Устанавливает деньги на {C:money}$0",
					"Дает {C:money}$#1#{} за каждый ваш {C:attention}ваучер",
                    "Дает {C:money}$#2#{} за каждый",
					"уровень ваших {C:attention}покерных рук"
				},
                unlock={
                    "Открыть каждую карту",
					"таро масти {E:1,C:tarot}Пентакли"
                }
			},
			c_ma_wand = {
				name = "Жезл",
				text = {
					"Карты в руке",
					"получают {C:attention}улучшение{}",
					"{C:attention}1{} выбранной карты",
					"{C:green}#1# из #2#{} шанс",
					"уничтожить карту в руке"
				},
                unlock={
                    "Открыть каждую карту",
					"таро масти {E:1,C:tarot}Жезлы"
                }
			},
			c_ma_sword = {
				name = "Меч",
				text = {
					"Понижает уровень всех {C:attention}покерных рук{} на {C:attention}#1#{}",
					"Добавьте {C:blue}синюю печать{} выбранной карте",
					"и соседним картам",
					"Если выбранная карта имеет {C:blue}синюю печать{},",
					"улучшите печать до {C:blue}звездной печати{}"
				},
                unlock={
                    "Открыть каждую карту",
					"таро масти {E:1,C:tarot}Мечи"
                }
			}
		},
		Other = {
			ma_stellar_seal = {
                name="Звездная печать",
                text={
                    "Создает карту {C:planet}планеты{}",
                    "для последней разыгранной {C:attention}покерной руки{}",
                    "раунда, если {C:attention}есть{} в руке",
					"{C:green}#1# из #2#{} шанс создать",
					"{C:dark_edition}негативную{} копию этой {C:planet}планеты",
                    "{C:inactive}(Должно быть место)"
                },
			}
		}
	}
}
