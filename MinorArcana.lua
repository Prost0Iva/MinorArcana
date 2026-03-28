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
SMODS.Atlas({key = 'modicon', path = 'Icon.png', px = 32, py = 32})
SMODS.Atlas({key = 'ma_tarot', path = 'Tarot.png', px = 71, py = 95})
SMODS.Atlas({key = 'ma_spectral', path = 'Spectral.png', px = 71, py = 95})
SMODS.Atlas({key = 'ma_seal', path = 'Seal.png', px = 71, py = 95})

--------------------------------------
--Функции, которые используются,
--для релизации механик карт
--------------------------------------
local igo = Game.init_game_object
function Game:init_game_object() --Хук на добавление своих переменных использующихся в партии
	local g = igo(self)
	g.tags_num = 0
    g.old_tags_num = 0
    g.last_sold_planet = nil
	return g
end

local upd = Game.update
function Game:update(dt) --Хук на выполнение каждый игровой кадр
    --Ниже идёт подсчёт полученных игроком тегов в партии, иных способ это посчитать я не придумал, 
    --но мне кажется они есть, и я сделал крайне не оптимизированно :/
    if G.GAME.old_tags_num < #G.GAME.tags then
        G.GAME.tags_num = G.GAME.tags_num + #G.GAME.tags - G.GAME.old_tags_num
        G.GAME.old_tags_num = #G.GAME.tags
    end
    if G.GAME.old_tags_num >= #G.GAME.tags then
        G.GAME.old_tags_num = #G.GAME.tags
    end

    upd(self, dt)
end

local sold_cards = Card.sell_card
function Card:sell_card()
	if self.config.center.set == 'Planet' then --Добавляю в код продажи кард запоминание последней проданной планеты
        G.GAME.last_sold_planet = self.config.center_key
    end
    
	sold_cards(self)
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
    cost = 3,
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
    cost = 3,
    pos = {x = 1, y = 0},

    config = {
        max_dollar = 40,
        extra = {
            dollar_per_tag = 2
        }
    },
    
    loc_vars = function (self, info_queue, card)
        return {vars = {
            card.ability.extra.dollar_per_tag,
            self.config.max_dollar,
            math.min(G.GAME.tags_num * card.ability.extra.dollar_per_tag,
            self.config.max_dollar
        )}}
    end,

    use = function (self, card, area, copier)
        local used_tarot = copier or card
        G.E_MANAGER:add_event(Event({
            trigger = 'before',
            delay = 0.6,
            func = (function()
                used_tarot:juice_up(0.3, 0.5)
                ease_dollars(math.min(G.GAME.tags_num * card.ability.extra.dollar_per_tag, self.config.max_dollar), true)
            return true
        end)}))
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
    cost = 3,
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

    use = function (self, card, area, copier)
    local used_tarot = copier or card
        if pseudorandom('knightcup') < G.GAME.probabilities.normal / card.ability.extra then --срабатывание шанса 1 к 3
            local what_tag = pseudorandom('knightcup') --рандомный выбор тэга
            if what_tag < 0.33 then
                add_tag(Tag('tag_foil'))
            end
            if 0.33 <= what_tag and what_tag < 0.66 then
                add_tag(Tag('tag_holo'))
            end
            if 0.66 <= what_tag and what_tag <= 1 then
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
    cost = 3,
    pos = {x = 3, y = 0},

    loc_vars = function (self, info_queue, card)
        info_queue[#info_queue+1] = G.P_TAGS.tag_charm;
        info_queue[#info_queue+1] = G.P_TAGS.tag_meteor;
        info_queue[#info_queue+1] = G.P_TAGS.tag_ethereal;
    end,

    use = function (self, card, area, copier)
        local what_tag = pseudorandom('queencup')
        if what_tag < 0.33 then
            add_tag(Tag('tag_charm'))
        end
        if 0.33 <= what_tag and what_tag < 0.66 then
            add_tag(Tag('tag_meteor'))
        end
        if 0.66 <= what_tag and what_tag <= 1 then
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
    cost = 3,
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
    cost = 3,
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
    cost = 3,
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
    cost = 3,
    pos = {x = 2, y = 1},

    use = function (self, card, area, copier)
        local what_tag = pseudorandom('knightpen')
        if what_tag < .2 then
            add_tag(Tag('tag_investment'))
        end
        if .2 <= what_tag and what_tag < .4 then
            add_tag(Tag('tag_handy'))
        end
        if .4 <= what_tag and what_tag < .6 then
            add_tag(Tag('tag_garbage'))
        end
        if .6 <= what_tag and what_tag < .8 then
            add_tag(Tag('tag_economy'))
        end
        if .8 <= what_tag and what_tag <= 1 then
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
    cost = 3,
    pos = {x = 3, y = 1},

    config = {
        extra = 2
    },

    loc_vars = function (self, info_queue, card)
        info_queue[#info_queue+1] = G.P_TAGS.tag_coupon;
        return {vars = {(G.GAME.probabilities.normal or 1), card.ability.extra}}
    end,

    use = function (self, card, area, copier)
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
    cost = 3,
    pos = {x = 4, y = 1},

    loc_vars = function (self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.j_credit_card
    end,

    use = function (self, card, area, copier)
        local credit_card = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_credit_card")
        credit_card:set_edition('e_negative', true)
        credit_card:add_sticker('perishable', true)
        credit_card:add_to_deck()
		G.jokers:emplace(credit_card)
    end,

    can_use = function (self, card)
        return true
    end

}

SMODS.Consumable{ --Ace of Wands
    set = 'Tarot',
    atlas = 'ma_tarot',
    key = 'acewand',
    unlocked = true,
    discovered = false,
    cost = 3,
    pos = {x = 0, y = 2},

    config = {
        extra = 4
    },

    loc_vars = function (self, info_queue, card)
        return {vars = {card.ability.extra}}
    end,

    use = function (self, card, area, copier)
        for i=1, #G.hand.highlighted do --переворачиваем выбранные карты
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('card1', percent);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
        end
        for i = 1, #G.hand.highlighted do --даём им случайное улучшение
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4,
            func = function ()
                G.hand.highlighted[i]:set_ability(G.P_CENTERS[SMODS.poll_enhancement({guaranteed = true, key = 'wands'})])
                return true 
            end 
          }))
        end
        for i=1, #G.hand.highlighted do --переворачиваем обратно
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('card1', percent);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
        end
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end })) --делаем все карты в руке не выделенными
    end,

    can_use = function(self, card)
        if G.hand and (#G.hand.highlighted >= 1) and (#G.hand.highlighted <= card.ability.extra) then
            return true
        end
    end

}

SMODS.Consumable{ --Page of Wands
    set = 'Tarot',
    atlas = 'ma_tarot',
    key = 'pagewand',
    unlocked = true,
    discovered = false,
    cost = 3,
    pos = {x = 1, y = 2},

    config = {
        extra = {
            max_highlight = 3,
            chance = 4
        }
    },

    loc_vars = function (self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_glass;
        return {vars = {
            (G.GAME.probabilities.normal or 1),
            card.ability.extra.chance,
            card.ability.extra.max_highlight
        }}
    end,

    use = function (self, card, area, copier)
        local used_tarot = copier or card
        if pseudorandom('pagewan') < G.GAME.probabilities.normal / card.ability.extra.chance then
            for i=1, #G.hand.highlighted do
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('card1', percent);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
            end
            for i = 1, #G.hand.highlighted do
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4,
                func = function ()
                    G.hand.highlighted[i]:set_ability(G.P_CENTERS.m_glass)
                    return true end }))
            end
            for i=1, #G.hand.highlighted do
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('card1', percent);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
            end
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
            delay(0.5)
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
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
    end,

    can_use = function(self, card)
        if G.hand and (#G.hand.highlighted >= 1) and (#G.hand.highlighted <= card.ability.extra.max_highlight) then
            return true
        end
    end

}

SMODS.Consumable{ --Knight of Wands
    set = 'Tarot',
    atlas = 'ma_tarot',
    key = 'knightwand',
    unlocked = true,
    discovered = false,
    cost = 3,
    pos = {x = 2, y = 2},

    config = {
        max_highlight = 1
    },

    loc_vars = function (self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_stone;
        return {vars = {
            self.config.max_highlight
        }}
    end,

    use = function (self, card, area, copier)
        local adjacent_cards = {} --ищем в картах руки расположение выбранной нами карты и её соседей и добавляем их в массив
        for i = 1, #G.hand.cards do
            if G.hand.cards[i] == G.hand.highlighted[1] then 
                    if G.hand.cards[i-1] then
                        adjacent_cards[#adjacent_cards + 1] = G.hand.cards[i-1]
                    end
                    if G.hand.cards[i+1] then
                        adjacent_cards[#adjacent_cards + 1] = G.hand.cards[i+1]
                    end
                break 
            end
        end

        for i = 1, #adjacent_cards do --теперь поочерёдно улучшаем её соседей, до каменных
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() adjacent_cards[i]:flip();play_sound('card1', percent);adjacent_cards[i]:juice_up(0.3, 0.3);return true end }))
        end
        for i = 1, #adjacent_cards do
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4,func = function () adjacent_cards[i]:set_ability(G.P_CENTERS.m_stone) return true end }))
        end
        for i = 1, #adjacent_cards do
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() adjacent_cards[i]:flip();play_sound('card1', percent);adjacent_cards[i]:juice_up(0.3, 0.3);return true end }))
        end

        G.E_MANAGER:add_event(Event({ --уничтожаем выбранную карту
                trigger = 'after',
                delay = 0.2,
                func = function() 
                    local highlighted_card = G.hand.highlighted[1]
                    if highlighted_card.ability.name == 'Glass Card' then 
                        highlighted_card:shatter()
                    else
                        highlighted_card:start_dissolve()
                    end
        return true end }))
    end,

    can_use = function(self, card)
        if G.hand and (#G.hand.highlighted >= 1) and (#G.hand.highlighted <= self.config.max_highlight) then
            return true
        end
    end

}

SMODS.Consumable{ --Queen of Wands
    set = 'Tarot',
    atlas = 'ma_tarot',
    key = 'queenwand',
    unlocked = true,
    discovered = false,
    cost = 3,
    pos = {x = 3, y = 2},

    config = {
        extra = 1
    },

    loc_vars = function (self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_gold;
        return {vars = {
            card.ability.extra
        }}
    end,

    use = function (self, card, area, copier)
        for i=1, #G.hand.highlighted do
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('card1', percent);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
        end
        for i=1, #G.hand.highlighted do
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4,func = function () G.hand.highlighted[i]:set_ability(G.P_CENTERS.m_gold) return true end }))
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function() --ивент на повышение ранга карты (взят прямиком из кода карты таро Сила)
                local card = G.hand.highlighted[i]
                local suit_prefix = string.sub(card.base.suit, 1, 1)..'_'
                local rank_suffix = card.base.id == 14 and 2 or math.min(card.base.id+1, 14)
                if rank_suffix < 10 then rank_suffix = tostring(rank_suffix)
                elseif rank_suffix == 10 then rank_suffix = 'T'
                elseif rank_suffix == 11 then rank_suffix = 'J'
                elseif rank_suffix == 12 then rank_suffix = 'Q'
                elseif rank_suffix == 13 then rank_suffix = 'K'
                elseif rank_suffix == 14 then rank_suffix = 'A'
                end
                card:set_base(G.P_CARDS[suit_prefix..rank_suffix])
            return true end }))
        end 
        for i=1, #G.hand.highlighted do
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('card1', percent);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
        end
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
    end,

    can_use = function(self, card)
        if G.hand and (#G.hand.highlighted >= 1) and (#G.hand.highlighted <= card.ability.extra) then
            return true
        end
    end

}

SMODS.Consumable{ --King of Wands
    set = 'Tarot',
    atlas = 'ma_tarot',
    key = 'kingwand',
    unlocked = true,
    discovered = false,
    cost = 3,
    pos = {x = 4, y = 2},

    config = {
        extra = 2
    },

    loc_vars = function (self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_steel;
        info_queue[#info_queue+1] = G.P_CENTERS.m_wild;
        return {vars = {
            card.ability.extra
        }}
    end,

    use = function (self, card, area, copier)
        for i=1, #G.hand.highlighted do
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('card1', percent);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
        end
        for i=1, #G.hand.highlighted do
            if G.hand.highlighted[i]:is_face() then
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4,func = function () G.hand.highlighted[i]:set_ability(G.P_CENTERS.m_steel) return true end }))
            else
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4,func = function () G.hand.highlighted[i]:set_ability(G.P_CENTERS.m_wild) return true end }))
            end
        end 
        for i=1, #G.hand.highlighted do
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('card1', percent);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
        end
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
    end,

    can_use = function(self, card)
        if G.hand and (#G.hand.highlighted >= 1) and (#G.hand.highlighted <= card.ability.extra) then
            return true
        end
    end

}

SMODS.Consumable{ --Ace of Swords
    set = 'Tarot',
    atlas = 'ma_tarot',
    key = 'acesword',
    unlocked = true,
    discovered = false,
    cost = 3,
    pos = {x = 0, y = 3},

    config = {
        extra = 2
    },

    loc_vars = function (self, info_queue, card)
        local now_hand, planet, smallest = nil, nil, 999999
        for k, v in ipairs(G.handlist) do
            if G.GAME.hands[v].visible and G.GAME.hands[v].played < smallest and G.GAME.hands[v].played ~= 0 then
                now_hand = v
                smallest = G.GAME.hands[v].played
            end
        end
        if now_hand then
            for k, v in pairs(G.P_CENTER_POOLS.Planet) do
                if v.config.hand_type == now_hand then
                    planet = v
                end
            end
        end
        local smallest_planet = planet and localize{type = 'name_text', key = planet.key, set = planet.set} or localize('k_none')
        local colour = not planet and G.C.RED or G.C.GREEN
        local main_end = { --Таблицу "Описания после" взял у дурака
            {n=G.UIT.C, config={align = "bm", padding = 0.02}, nodes={
                {n=G.UIT.C, config={align = "m", colour = colour, r = 0.05, padding = 0.05}, nodes={
                    {n=G.UIT.T, config={text = ' '..smallest_planet..' ', colour = G.C.UI.TEXT_LIGHT, scale = 0.3, shadow = true}},
                }}
            }}
        }
        info_queue[#info_queue+1] = planet;
        return {
            vars = {
                card.ability.extra
                },
			main_end = main_end --Вот так надо добавлять особое описание после основного
        }
    end,

    use = function (self, card, area, copier)
        local now_hand, planet, smallest = nil, nil, 999999 --перебираем все руки и ищем наименее часто использованную
                                                            --(как показали тесты: если рук не разыгрывалось вообще, то даёт карты старшей карты,
                                                            --а если разыгранное количество одинаковое - той что разыгрывалась последний раз)
        for k, v in ipairs(G.handlist) do
            if G.GAME.hands[v].visible and G.GAME.hands[v].played < smallest and G.GAME.hands[v].played ~= 0 then
                now_hand = v
                smallest = G.GAME.hands[v].played
            end
        end
        if now_hand then
            for k, v in pairs(G.P_CENTER_POOLS.Planet) do
                if v.config.hand_type == now_hand then
                    planet = v.key
                end
            end
        end

        for i = 1, math.min(card.ability.extra, G.consumeables.config.card_limit - #G.consumeables.cards) do --создаем карты планет, в зависимости от свободного места под расходники
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                if G.consumeables.config.card_limit > #G.consumeables.cards then
                    play_sound('timpani')
                    local planet_card = create_card('Planet', G.consumeables, nil, nil, nil, nil, planet)
                    planet_card:add_to_deck()
                    G.consumeables:emplace(planet_card)
                    card:juice_up(0.3, 0.5)
                end
            return true end }))
        end
        delay(0.6)
    end,

    can_use = function()
        return true
    end

}

SMODS.Consumable{ --Page of Swords
    set = 'Tarot',
    atlas = 'ma_tarot',
    key = 'pagesword',
    unlocked = true,
    discovered = false,
    cost = 3,
    pos = {x = 1, y = 3},

    config = {
        extra = 1
    },

    loc_vars = function (self, info_queue, card)
        local now_hand, planet, biggest = nil, nil, 0 --Ищем наиболее часто играемую руку и даем её столько раз, сколько кард уничтожили
        for k, v in ipairs(G.handlist) do
            if G.GAME.hands[v].visible and G.GAME.hands[v].played > biggest and G.GAME.hands[v].played ~= 0 then
                now_hand = v
                biggest = G.GAME.hands[v].played
            end
        end
        if now_hand then
            for k, v in pairs(G.P_CENTER_POOLS.Planet) do
                if v.config.hand_type == now_hand then
                    planet = v
                end
            end
        end
        local most_planet = planet and localize{type = 'name_text', key = planet.key, set = planet.set} or localize('k_none')
        local colour = not planet and G.C.RED or G.C.GREEN
        local main_end = {
            {n=G.UIT.C, config={align = "bm", padding = 0.02}, nodes={
                {n=G.UIT.C, config={align = "m", colour = colour, r = 0.05, padding = 0.05}, nodes={
                    {n=G.UIT.T, config={text = ' '..most_planet..' ', colour = G.C.UI.TEXT_LIGHT, scale = 0.3, shadow = true}},
                }}
            }}
        }
        info_queue[#info_queue+1] = planet;
        return {
            vars = {
                card.ability.extra
                },
			main_end = main_end
        }
    end,

    use = function (self, card, area, copier)
        local destroed_val = 0 --Уничтожаем выбранные карты и считаем их количество
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function() 
                for i=#G.hand.highlighted, 1, -1 do
                    destroed_val = destroed_val + 1
                    local destroing_card = G.hand.highlighted[i]
                    if destroing_card.ability.name == 'Glass Card' then 
                        destroing_card:shatter()
                    else
                        destroing_card:start_dissolve()
                    end
                end
            return true end }))
        
        local now_hand, planet, biggest = nil, nil, 0 --Ищем наиболее часто играемую руку и даем её столько раз, сколько кард уничтожили
        for k, v in ipairs(G.handlist) do
            if G.GAME.hands[v].visible and G.GAME.hands[v].played > biggest and G.GAME.hands[v].played ~= 0 then
                now_hand = v
                biggest = G.GAME.hands[v].played
            end
        end
        if now_hand then
            for k, v in pairs(G.P_CENTER_POOLS.Planet) do
                if v.config.hand_type == now_hand then
                    planet = v.key
                end
            end
        end
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
            for i = 1, math.min(destroed_val, G.consumeables.config.card_limit - #G.consumeables.cards) do
                if G.consumeables.config.card_limit > #G.consumeables.cards then
                    play_sound('timpani')
                    local planet_card = create_card('Planet', G.consumeables, nil, nil, nil, nil, planet)
                    planet_card:add_to_deck()
                    G.consumeables:emplace(planet_card)
                    card:juice_up(0.3, 0.5)
                end
            end
        return true end }))
    end,

    can_use = function(self, card)
        if G.hand and (#G.hand.highlighted >= 1) and (#G.hand.highlighted <= card.ability.extra) then
            return true
        end
    end

}

SMODS.Consumable{ --Knight of Swords
    set = 'Tarot',
    atlas = 'ma_tarot',
    key = 'knightsword',
    unlocked = true,
    discovered = false,
    cost = 3,
    pos = {x = 2, y = 3},

    config = {
        extra = 2
    },

    loc_vars = function (self, info_queue, card)
        local sold_planet = G.GAME.last_sold_planet and localize{type = 'name_text', key = G.P_CENTERS[G.GAME.last_sold_planet].key, set = G.P_CENTERS[G.GAME.last_sold_planet].set} or localize('k_none')
        local colour = not G.GAME.last_sold_planet and G.C.RED or G.C.GREEN
        local main_end = {
            {n=G.UIT.C, config={align = "bm", padding = 0.02}, nodes={
                {n=G.UIT.C, config={align = "m", colour = colour, r = 0.05, padding = 0.05}, nodes={
                    {n=G.UIT.T, config={text = ' '..sold_planet..' ', colour = G.C.UI.TEXT_LIGHT, scale = 0.3, shadow = true}},
                }}
            }}
        }
        info_queue[#info_queue+1] = G.P_CENTERS[G.GAME.last_sold_planet];
        return {
            vars = {
                G.GAME.probabilities.normal,
                card.ability.extra
                },
			main_end = main_end
        }
    end,

    use = function (self, card, area, copier)

        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function() --Ивент на создание последней проданой карты планет
            if G.consumeables.config.card_limit > #G.consumeables.cards then           --Чтобы понять откуда я беру последнюю проданую карту см. строку 46-50
                play_sound('timpani')
                local planet_card = create_card('Planet', G.consumeables, nil, nil, nil, nil, G.GAME.last_sold_planet)
                planet_card:add_to_deck()
                G.consumeables:emplace(planet_card)
                card:juice_up(0.3, 0.5)
            end
            return true end }))
        delay(0.6)
        
        if pseudorandom('knightsword') < G.GAME.probabilities.normal / card.ability.extra then --Ну и дублирую эффект с шансом
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                if G.consumeables.config.card_limit > #G.consumeables.cards then
                    play_sound('timpani')
                    local planet_card = create_card('Planet', G.consumeables, nil, nil, nil, nil, G.GAME.last_sold_planet)
                    planet_card:add_to_deck()
                    G.consumeables:emplace(planet_card)
                    card:juice_up(0.3, 0.5)
                end
                return true end }))
            delay(0.6)
        else
            local used_tarot = copier or card
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

    can_use = function()
        if G.GAME.last_sold_planet then return true end
    end

}

SMODS.Consumable{ --Queen of Swords
    set = 'Tarot',
    atlas = 'ma_tarot',
    key = 'queensword',
    unlocked = true,
    discovered = false,
    cost = 3,
    pos = {x = 3, y = 3},

    config = {
        extra = {
            chance = 4,
            lvl = 2
        }
    },

    loc_vars = function (self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.j_space;
        return {
            vars = {
                G.GAME.probabilities.normal,
                card.ability.extra.chance,
                card.ability.extra.lvl
                }
        }
    end,

    use = function (self, card, area, copier)
        local used_tarot = copier or card
        if pseudorandom('queensword') < G.GAME.probabilities.normal*3 / card.ability.extra.chance then --Перебираем все руки и берём рандомную, ур которой больше 2
            local hand = nil                                                                               --Далее с помощью функции SMODS.smart_level_up_hand уменьшаем уровень этой руки
            for k, v in ipairs(G.handlist) do                                                              --На самом деле я хотел сделать так, чтобы ур руки мог быть отрицательным, но код игры не позволяет уменьшить ур уже отрицательной руки :(
                if G.GAME.hands[v].visible and G.GAME.hands[v].level > 2 and pseudorandom('downhand') > .4 then
                    hand = v
                end
            end
            if not hand and G.GAME.hands["High Card"].level > 2 then
                hand = "High Card"
            end
            if hand then
                SMODS.smart_level_up_hand(card, hand, false, -(card.ability.extra.lvl))
            end
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

        local cosmo_card = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_space")
        cosmo_card:set_edition('e_negative', true)
        cosmo_card:add_sticker('perishable', true)
        cosmo_card:add_sticker('rental', true)
        cosmo_card:add_to_deck()
		G.jokers:emplace(cosmo_card)
    end,

    can_use = function()
        return true
    end

}

SMODS.Consumable{ --King of Swords
    set = 'Tarot',
    atlas = 'ma_tarot',
    key = 'kingsword',
    unlocked = true,
    discovered = false,
    cost = 3,
    pos = {x = 4, y = 3},

    config = {
        extra = {
            chance = 5,
            chance_add = 3
        }
    },

    loc_vars = function (self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.c_black_hole;
        return {
            vars = {
                G.GAME.probabilities.normal,
                card.ability.extra.chance,
                card.ability.extra.chance_add
                }
        }
    end,

    use = function (self, card, area, copier)
        local used_tarot = copier or card
        if pseudorandom('kingsword') < G.GAME.probabilities.normal / card.ability.extra.chance then --Тут мы просто выдаем с шансом черную дыру и с другим шансом создаем её негативную копию
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                if G.consumeables.config.card_limit > #G.consumeables.cards then
                    play_sound('timpani')
                    local black_hole_card = create_card('Spectral', G.consumeables, nil, nil, nil, nil, "c_black_hole")
                    black_hole_card:add_to_deck()
                    G.consumeables:emplace(black_hole_card)
                    card:juice_up(0.3, 0.5)
                end
                return true end }))
            delay(0.6)
            if pseudorandom('kingswordadd') < G.GAME.probabilities.normal / card.ability.extra.chance_add then
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                    play_sound('timpani')
                    local black_hole_card = create_card('Spectral', G.consumeables, nil, nil, nil, nil, "c_black_hole")
                    black_hole_card:set_edition('e_negative', true)
                    black_hole_card:add_to_deck()
                    G.consumeables:emplace(black_hole_card)
                    card:juice_up(0.3, 0.5)
                    return true end }))
                delay(0.6)
            end
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

    can_use = function()
        return true
    end

}

SMODS.Consumable{ --Cup
    set = 'Spectral',
    atlas = 'ma_spectral',
    key = 'cup',

    unlocked = false,
    check_for_unlock = function(self, args) --условия для разблокировки карты (сейчас необходимо найти все карты кубков в игре)
        if G.P_CENTERS["c_ma_acecup"].discovered and
        G.P_CENTERS["c_ma_pagecup"].discovered and
        G.P_CENTERS["c_ma_knightcup"].discovered and
        G.P_CENTERS["c_ma_queencup"].discovered and
        G.P_CENTERS["c_ma_kingcup"].discovered then
            unlock_card(self)
        end
    end,

    discovered = false,
    cost = 4,
    pos = {x = 0, y = 0},

    config = {
        extra = 8
    },

    loc_vars = function (self, info_queue, card)
        return {
            vars = {
                card.ability.extra
                }
        }
    end,

    use = function (self, card, area, copier)
        local used_tarot, t_val = copier or card, 0
        for k, v in pairs(G.P_TAGS) do --считаем количество тегов в игре
            t_val = t_val + 1 
        end
        for k, v in ipairs(G.consumeables.cards) do --уничтожаем все расходники игрока
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                v:shatter()
                play_sound('tarot2', 0.76, 0.4)
                used_tarot:juice_up(0.3, 0.5)
            ;return true end}))
        end
        for i = 1, card.ability.extra do --выдаем случайные тэги
            local r, x = math.random(t_val), 1
            for k, v in pairs(G.P_TAGS) do
                if x == r then
                    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                        add_tag(Tag(k))
                        play_sound('tarot2', 0.76, 0.4)
                        used_tarot:juice_up(0.3, 0.5)
                    return true end}))
                    break
                end
                x = x + 1
            end
        end
    end,

    can_use = function()
        return true
    end

}

SMODS.Consumable{ --Pentacle
    set = 'Spectral',
    atlas = 'ma_spectral',
    key = 'pentacle',

    unlocked = false,
    check_for_unlock = function(self, args)
        if G.P_CENTERS["c_ma_acepen"].discovered and
        G.P_CENTERS["c_ma_pagepen"].discovered and
        G.P_CENTERS["c_ma_knightpen"].discovered and
        G.P_CENTERS["c_ma_queenpen"].discovered and
        G.P_CENTERS["c_ma_kingpen"].discovered then
            unlock_card(self)
        end
    end,

    discovered = false,
    cost = 4,
    pos = {x = 1, y = 0},

    config = {
        extra = {
            per_vouch = 9,
            per_lvl = 1
        }
    },

    loc_vars = function (self, info_queue, card)
        return {
            vars = {
                card.ability.extra.per_vouch,
                card.ability.extra.per_lvl
                }
        }
    end,


    use = function (self, card, area, copier)
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function() --обнуляем деньги игрока
            card:juice_up(0.3, 0.5)
            if G.GAME.dollars ~= 0 then
                ease_dollars(-G.GAME.dollars, true)
            end
            delay(0.4)
        return true end }))

        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
            local lvl_val, vouch_val = 0, 0
            for k, v in pairs(G.GAME.used_vouchers) do --считаем количество ваучеров игрока
                    vouch_val = vouch_val + 1
            end
            for k, v in ipairs(G.handlist) do --считаем сумму уровней всех рук игрока (при условии что они не скрыты)
                if G.GAME.hands[v].visible then
                    lvl_val = lvl_val + G.GAME.hands[v].level
                end
            end
            ease_dollars(card.ability.extra.per_lvl * lvl_val, true) --выдаем деньги за кажд ваучер и уровень
            ease_dollars(card.ability.extra.per_vouch * vouch_val, true)
            card:juice_up(0.3, 0.5)
        return true end }))
        delay(0.6)
    end,

    can_use = function()
        return true
    end

}

SMODS.Consumable{ --Wand
    set = 'Spectral',
    atlas = 'ma_spectral',
    key = 'wand',

    unlocked = false,
    check_for_unlock = function(self, args)
        if G.P_CENTERS["c_ma_acewand"].discovered and
        G.P_CENTERS["c_ma_pagewand"].discovered and
        G.P_CENTERS["c_ma_knightwand"].discovered and
        G.P_CENTERS["c_ma_queenwand"].discovered and
        G.P_CENTERS["c_ma_kingwand"].discovered then
            unlock_card(self)
        end
    end,

    discovered = false,
    cost = 4,
    pos = {x = 2, y = 0},

    config = {
        extra = 3
    },

    loc_vars = function (self, info_queue, card)
        return {
            vars = {
                G.GAME.probabilities.normal,
                card.ability.extra
            }
        }
    end,

    use = function (self, card, area, copier)
        for i = 1, #G.hand.cards do
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.cards[i]:flip();play_sound('card1', percent);G.hand.cards[i]:juice_up(0.3, 0.3);return true end }))
        end

        local to_destroy = {}
        for k, v in ipairs(G.hand.cards) do
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4,func = function ()
                local abil = nil
                for k, v in pairs(G.P_CENTERS) do
                    if G.P_CENTERS[k].name == G.hand.highlighted[1].ability.name then --ищем улучшение карты в таблице всех улучшений игры и выдаем его всем картам в руке 
                        abil = v
                        break
                    end
                end
                G.hand.cards[k]:set_ability(abil)
                G.hand.cards[k]:juice_up(0.3, 0.3)
                if pseudorandom('wand') < G.GAME.probabilities.normal / card.ability.extra then --а также добавляем карты на которых сработал шанс в массив на удаление
                    to_destroy[#to_destroy + 1] = G.hand.cards[k]
                    card:juice_up(0.3, 0.3)
                end
            return true end }))
        end
        
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.1,func = function () --удаляем все карты массива
            sendInfoMessage(#to_destroy)
            for i = 0, #to_destroy do
                if to_destroy[i] then
                    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4,func = function ()
                        to_destroy[i]:shatter()
                        card:juice_up(0.3, 0.3)
                    return true end }))
                end
            end
        return true end }))

        for i = 1, #G.hand.cards do
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function()
                if G.hand.cards[i] then
                    G.hand.cards[i]:flip()
                    play_sound('card1', percent)
                    G.hand.cards[i]:juice_up(0.3, 0.3)
                end
            return true end }))
        end
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
    end,

    can_use = function()
        if G.hand and #G.hand.highlighted == 1 then
            return true
        end
    end

}

SMODS.Seal{ --Stellar Seal
    key = 'stellar',
    atlas = 'ma_seal',
    pos = {x = 0, y = 0},
    config = {
        extra = 3
    },
	badge_colour = G.C.BLUE,
    loc_vars = function (self, info_queue, card)
        return {vars = {
            (G.GAME.probabilities.normal or 1),
            self.config.extra
        }}
    end,
    calculate = function(self, card, context)
        --if context.final_scoring_step and context.cardarea == G.hand --ВОТ ТУТ МЫ ПИШЕМ КОНТЕКСТ
        if context.end_of_round and context.cardarea == G.hand and context.playing_card_end_of_round --ВОТ ТУТ МЫ ПИШЕМ КОНТЕКСТ
        then
            return { func = function() --Я ООООЧЕНЬ ДОЛГО НЕ ПОНИМАЛ, ПОЧЕМУ МИМ НЕ РАБОТАЕТ С МОЕЙ ПЕЧАТЬЮ, ТАК ВОТ, ДЕЛО В ТОМ, ЧТО, ЧТОБЫ ЧТОТО СЧИТАЛОСЬ ЭФФЕКТОМ КАРТЫ НАДО НЕ ПРОСТО ВЫЗЫВАТЬ, А ВОЗВРАЩАТЬ ФУНКЦИЮ И ЭТО КАЗАЛОСЬ БЫ ТАК ПРОСТО, НО Я НА ПОНИМАНИЕ ЭТОГО ПОТРАТИЛ 2 ДНЯ............ я устал..... я даже за это деег не получу.... а ещё это никто не прочитает.. я пошёл плакать
                local rng = pseudorandom('stellar')
                G.E_MANAGER:add_event(Event({ trigger = 'before', delay = 0.0, func = (function()
                    if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then --в конце раунда создает карту планеты последней сыграной руки
                        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                        if G.GAME.last_hand_played then
                            local planet = nil
                            for k, v in pairs(G.P_CENTER_POOLS.Planet) do
                                if v.config.hand_type == G.GAME.last_hand_played then
                                    planet = v.key
                                end
                            end
                            local planet_card = create_card('Planet', G.consumeables, nil, nil, nil, nil, planet)
                            planet_card:add_to_deck()
                            G.consumeables:emplace(planet_card)
                            G.GAME.consumeable_buffer = 0
                        end
                    end
                    if rng < G.GAME.probabilities.normal / self.config.extra then
                        if G.GAME.last_hand_played then
                            local planet = nil
                            for k, v in pairs(G.P_CENTER_POOLS.Planet) do
                                if v.config.hand_type == G.GAME.last_hand_played then
                                    planet = v.key
                                end
                            end
                            local add_planet_card = create_card('Planet', G.consumeables, nil, nil, nil, nil, planet)
                            add_planet_card:set_edition('e_negative', true)
                            add_planet_card:add_to_deck()
                            G.consumeables:emplace(add_planet_card)
                        end
                    end
                return true end)}))
                if (#G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit) or (rng < G.GAME.probabilities.normal / self.config.extra) then
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_plus_planet'), colour = G.C.SECONDARY_SET.Planet})
                end
            end }
        end
    end,
}

SMODS.Consumable{ --Sword
    set = 'Spectral',
    atlas = 'ma_spectral',
    key = 'sword',

    unlocked = false,
    check_for_unlock = function(self, args)
        if G.P_CENTERS["c_ma_acesword"].discovered and
        G.P_CENTERS["c_ma_pagesword"].discovered and
        G.P_CENTERS["c_ma_knightsword"].discovered and
        G.P_CENTERS["c_ma_queensword"].discovered and
        G.P_CENTERS["c_ma_kingsword"].discovered then
            unlock_card(self)
        end
    end,

    discovered = false,
    cost = 4,
    pos = {x = 3, y = 0},

    config = {
        extra = 1
    },

    loc_vars = function (self, info_queue, card)
        info_queue[#info_queue+1] = G.P_SEALS.Blue
        info_queue[#info_queue+1] = G.P_SEALS.ma_stellar
        return {
            vars = {
                card.ability.extra
            }
        }
    end,

    use = function (self, card, area, copier)
        local used_tarot = copier or card

        update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize('k_all_hands'),chips = '...', mult = '...', level=''})
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
            play_sound('tarot1')
            used_tarot:juice_up(0.8, 0.5)
            G.TAROT_INTERRUPT_PULSE = true
            return true end }))
        update_hand_text({delay = 0}, {mult = '-', StatusText = true})
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.9, func = function()
            play_sound('tarot1')
            used_tarot:juice_up(0.8, 0.5)
            return true end }))
        update_hand_text({delay = 0}, {chips = '-', StatusText = true})
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.9, func = function()
            play_sound('tarot1')
            used_tarot:juice_up(0.8, 0.5)
            G.TAROT_INTERRUPT_PULSE = nil
            return true end }))
        update_hand_text({sound = 'button', volume = 0.7, pitch = 0.9, delay = 0}, {level='-1'})
        delay(1.3)
        local to_level_down = {} --Понижение уровня всех покерных рук
        for k, v in ipairs(G.handlist) do
            if G.GAME.hands[v].level > 1 then
                to_level_down[#to_level_down + 1] = v
            end
        end
        for k, v in ipairs(to_level_down) do
            SMODS.smart_level_up_hand(card, v, true, -(card.ability.extra))
        end
        update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})

        if G.hand.highlighted[1].seal == 'Blue' then
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.6,func = function()
                play_sound('tarot1')
                used_tarot:juice_up(0.3, 0.5)
                G.hand.highlighted[1]:set_seal('ma_stellar')
            return true end }))
        else
            local adjacent_cards = {} --ищем в картах руки расположение выбранной нами карты и её соседей и добавляем их в массив
            for i = 1, #G.hand.cards do
                if G.hand.cards[i] == G.hand.highlighted[1] then 
                        if G.hand.cards[i-1] then
                            adjacent_cards[#adjacent_cards + 1] = G.hand.cards[i-1]
                        end
                        adjacent_cards[#adjacent_cards + 1] = G.hand.cards[i]
                        if G.hand.cards[i+1] then
                            adjacent_cards[#adjacent_cards + 1] = G.hand.cards[i+1]
                        end
                    break 
                end
            end
            for i = 1, #adjacent_cards do
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4,func = function () used_tarot:juice_up(0.3, 0.5) play_sound('tarot1') adjacent_cards[i]:set_seal('Blue') return true end }))
            end
        end
    end,

    can_use = function(self, card)
        if G.hand and #G.hand.highlighted == 1 then
            return true
        end
    end

}