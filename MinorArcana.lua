---------------------------------------------------------------------------------------------------------
--Привет, я Iva, это мой мод - MinorArcana
--Мод довольно ваннильный, добавляет в игру младшие арканы карт таро, со своими уникальными способностями.
--Это сообщение для тех, кто хочет начать писать моды для Балатро,
--так как в момент написания этого комментария, я сам с нуля изучаю эту стизю,
--надеюсь изучение работы моего мода и оставленные далее мной комментарии, помогут вам быстрее освоиться!
--Удачи, йоу 
--P.S. Добавлять подробные комментарии буду, только наиболее интересным вещам,
--остальное вам легче будет изучить самим в документации 
--самого smods (https://github.com/Steamodded/smods/wiki/API-Documentation)
---------------------------------------------------------------------------------------------------------

------------------------------
--Инициализация файлов текстур
------------------------------
SMODS.Atlas({key = 'ma_tarot', path = 'Tarots.png', px = 71, py = 95})

--------------------------------------
--Функции, которые используются,
--для релизации механик карт
--------------------------------------
local igo = Game.init_game_object
function Game:init_game_object() --Хук на добавление своих переменных использующихся в партии
	local g = igo(self)
	g.tags_num = 0
    g.old_tags_num = 0
	return g
end

local upd = Game.update
function Game:update(dt) --Хук на выполнение каждый игровой кадр
    --Ниже идёт подсчёт полученных игроком тегов в партии, иных способ это посчитать я не придумал, 
    --но мне кажется они есть, и я сделал крайне не оптимизированно :/
    if G.GAME.old_tags_num < #G.GAME.tags then --
        G.GAME.tags_num = G.GAME.tags_num + #G.GAME.tags - G.GAME.old_tags_num
        G.GAME.old_tags_num = #G.GAME.tags
    end
    if G.GAME.old_tags_num >= #G.GAME.tags then
        G.GAME.old_tags_num = #G.GAME.tags
    end

    upd(self, dt)
end

----------------
--Код карт таро
----------------
SMODS.Consumable{ --Ace of Cups
    set = 'Tarot',
    atlas = 'ma_tarot',
    key = 'acecup',
    unlocked = true,
    discovered = false,
    cost = 2,
    pos = {x = 0, y = 0},

    loc_vars = function (self, info_queue, card)
        info_queue[#info_queue+1] = G.P_TAGS.tag_boss
    end,

    use = function (self, card, area, copier)
        add_tag(Tag('tag_boss'))
    end,

    can_use = function (self, card)
        return true
    end

}

SMODS.Consumable{ --Page of Cups
    set = 'Tarot',
    atlas = 'ma_tarot',
    key = 'pagecup',
    unlocked = true,
    discovered = false,
    cost = 2,
    pos = {x = 1, y = 0},

    config = {
        max_dollar = 40,
        extra = {
            dollar_per_tag = 2
        }
    },
    
    loc_vars = function (self, info_queue, card)
        return {vars = {card.ability.extra.dollar_per_tag, self.config.max_dollar, math.min(G.GAME.tags_num * card.ability.extra.dollar_per_tag, self.config.max_dollar)}}
    end,

    use = function (self, card, area, copier)
        ease_dollars(math.min(G.GAME.tags_num * card.ability.extra.dollar_per_tag, self.config.max_dollar), true)
    end,
    
    can_use = function (self, card)
        return true
    end
}

SMODS.Consumable{ --Knight of Cups
    set = 'Tarot',
    atlas = 'ma_tarot',
    key = 'knightcup',
    unlocked = true,
    discovered = false,
    cost = 2,
    pos = {x = 2, y = 0},

    config = {
        extra = 3
    },

    loc_vars = function (self, info_queue, card)
        info_queue[#info_queue+1] = G.P_TAGS.tag_foil;
        info_queue[#info_queue+1] = G.P_TAGS.tag_holo;
        info_queue[#info_queue+1] = G.P_TAGS.tag_polychrome;
        return {vars = {(G.GAME.probabilities.normal or 1), card.ability.extra}}
    end,

    use = function (self, card, area, copier) --UJPFEAQP
    local used_tarot = copier or card
        if pseudorandom('knightcup') < G.GAME.probabilities.normal / card.ability.extra then --срабатывание шанса 1 к 3
            local what_tag = math.random(3) --рандомный выбор тэга
            if what_tag == 1 then
                add_tag(Tag('tag_foil'))
            end
            if what_tag == 2 then
                add_tag(Tag('tag_holo'))
            end
            if what_tag == 3 then
                add_tag(Tag('tag_polychrome'))
            end
        else
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function() --сообщение nope взятое у колеса фортуны 
                attention_text({
                    text = localize('k_nope_ex'),
                    scale = 1.3, 
                    hold = 1.4,
                    major = used_tarot,
                    backdrop_colour = G.C.SECONDARY_SET.Tarot,
                    align = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and 'tm' or 'cm',
                    offset = {x = 0, y = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and -0.2 or 0},
                    silent = true
                    })
                    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.06*G.SETTINGS.GAMESPEED, blockable = false, blocking = false, func = function()
                        play_sound('tarot2', 0.76, 0.4);return true end}))
                    play_sound('tarot2', 1, 0.4)
                    used_tarot:juice_up(0.3, 0.5)
            return true end }))
        end
    end,

    can_use = function (self, card)
        return true
    end
}

SMODS.Consumable{ --Queen of Cups
    set = 'Tarot',
    atlas = 'ma_tarot',
    key = 'queencup',
    unlocked = true,
    discovered = false,
    cost = 2,
    pos = {x = 3, y = 0},

    loc_vars = function (self, info_queue, card)
        info_queue[#info_queue+1] = G.P_TAGS.tag_charm;
        info_queue[#info_queue+1] = G.P_TAGS.tag_meteor;
        info_queue[#info_queue+1] = G.P_TAGS.tag_ethereal;
    end,

    use = function (self, card, area, copier)
        local what_tag = math.random(3)
        if what_tag == 1 then
            add_tag(Tag('tag_charm'))
        end
        if what_tag == 2 then
            add_tag(Tag('tag_meteor'))
        end
        if what_tag == 3 then
            add_tag(Tag('tag_ethereal'))
        end
    end,

    can_use = function (self, card)
        return true
    end
}

SMODS.Consumable{ --King of Cups
    set = 'Tarot',
    atlas = 'ma_tarot',
    key = 'kingcup',
    unlocked = true,
    discovered = false,
    cost = 2,
    pos = {x = 4, y = 0},

    loc_vars = function (self, info_queue, card)
        info_queue[#info_queue+1] = G.P_TAGS.tag_d_six;
    end,

    use = function (self, card, area, copier)
        add_tag(Tag('tag_d_six'))
    end,

    can_use = function (self, card)
        return true
    end
}

SMODS.Consumable{ --Ace of Pentacles
    set = 'Tarot',
    atlas = 'ma_tarot',
    key = 'acepen',
    unlocked = true,
    discovered = false,
    cost = 2,
    pos = {x = 0, y = 1},

    config = {
        currently = 0,
        max_dollar = 40,
        extra = {
            dollar_per_com = 2,
            dollar_per_uncom = 3,
            dollar_per_rare = 5,
            dollar_per_leg = 8
        }
    },

    loc_vars = function (self, info_queue, card)
        return{vars = {
            card.ability.extra.dollar_per_com,
            card.ability.extra.dollar_per_uncom,
            card.ability.extra.dollar_per_rare,
            card.ability.extra.dollar_per_leg,
            self.config.max_dollar,
            math.min(self.config.currently, self.config.max_dollar)

        }}
    end,

    update = function (self, card, dt) --считаем деньги за редкость каждого текущего джокера
        if G.jokers ~= nil then
            self.config.currently = 0
            for i = 1, (#G.jokers.cards) do
                if G.jokers.cards[i].config.center.rarity == 1 then
                    self.config.currently = self.config.currently + card.ability.extra.dollar_per_com
                end
                if G.jokers.cards[i].config.center.rarity == 2 then
                    self.config.currently = self.config.currently + card.ability.extra.dollar_per_uncom
                end
                if G.jokers.cards[i].config.center.rarity == 3 then
                    self.config.currently = self.config.currently + card.ability.extra.dollar_per_rare
                end
                if G.jokers.cards[i].config.center.rarity == 4 then
                    self.config.currently = self.config.currently + card.ability.extra.dollar_per_leg
                end
            end
        end
    end,

    use = function (self, card, area, copier)
        ease_dollars(math.min(self.config.currently, self.config.max_dollar), true)
    end,

    can_use = function (self, card)
        return true
    end
}

SMODS.Consumable{ --Page of Pentacles
    set = 'Tarot',
    atlas = 'ma_tarot',
    key = 'pagepen',
    unlocked = true,
    discovered = false,
    cost = 2,
    pos = {x = 1, y = 1},

    config = {
        currently = 0,
        max_dollar = 25,
        extra = {
            dollar_per_round = 1
        }
    },

    loc_vars = function (self, info_queue, card)
        return{vars = {
            card.ability.extra.dollar_per_round,
            self.config.max_dollar,
            math.min(self.config.currently, self.config.max_dollar)

        }}
    end,

    update = function (self, card, dt)
        if G.GAME ~= nil then
            self.config.currently = 0
            self.config.currently = self.config.currently + G.GAME.round * card.ability.extra.dollar_per_round
        end
    end,

    use = function (self, card, area, copier)
        ease_dollars(math.min(self.config.currently, self.config.max_dollar), true)
    end,

    can_use = function (self, card)
        return true
    end
}

SMODS.Consumable{ --Knight of Pentacles
    set = 'Tarot',
    atlas = 'ma_tarot',
    key = 'knightpen',
    unlocked = true,
    discovered = false,
    cost = 2,
    pos = {x = 2, y = 1},

    use = function (self, card, area, copier)
        local what_tag = math.random(5)
        if what_tag == 1 then
            add_tag(Tag('tag_investment'))
        end
        if what_tag == 2 then
            add_tag(Tag('tag_handy'))
        end
        if what_tag == 3 then
            add_tag(Tag('tag_garbage'))
        end
        if what_tag == 4 then
            add_tag(Tag('tag_economy'))
        end
        if what_tag == 5 then
            add_tag(Tag('tag_skip'))
        end
    end,

    can_use = function (self, card)
        return true
    end
}

SMODS.Consumable{ --Queen of Pentacles
    set = 'Tarot',
    atlas = 'ma_tarot',
    key = 'queenpen',
    unlocked = true,
    discovered = false,
    cost = 2,
    pos = {x = 3, y = 1},

    config = {
        extra = 2
    },

    loc_vars = function (self, info_queue, card)
        info_queue[#info_queue+1] = G.P_TAGS.tag_coupon;
        return {vars = {(G.GAME.probabilities.normal or 1), card.ability.extra}}
    end,

    use = function (self, card, area, copier) --UJPFEAQP
    local used_tarot = copier or card
        if pseudorandom('queenpen') < G.GAME.probabilities.normal / card.ability.extra then
            add_tag(Tag('tag_coupon'))
        else
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                attention_text({
                    text = localize('k_nope_ex'),
                    scale = 1.3, 
                    hold = 1.4,
                    major = used_tarot,
                    backdrop_colour = G.C.SECONDARY_SET.Tarot,
                    align = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and 'tm' or 'cm',
                    offset = {x = 0, y = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and -0.2 or 0},
                    silent = true
                    })
                    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.06*G.SETTINGS.GAMESPEED, blockable = false, blocking = false, func = function()
                        play_sound('tarot2', 0.76, 0.4);return true end}))
                    play_sound('tarot2', 1, 0.4)
                    used_tarot:juice_up(0.3, 0.5)
            return true end }))
        end
    end,

    can_use = function (self, card)
        return true
    end
}

SMODS.Consumable{ --King of Pentacles
    set = 'Tarot',
    atlas = 'ma_tarot',
    key = 'kingpen',
    unlocked = true,
    discovered = false,
    cost = 2,
    pos = {x = 4, y = 1},

    loc_vars = function (self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.j_credit_card
    end,

    use = function (self, card, area, copier)
        local card = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_credit_card")
        card:set_edition('e_negative', true)
        card:add_sticker('perishable', true)
        card:add_to_deck()
		G.jokers:emplace(card)
    end,

    can_use = function (self, card)
        return true
    end

}