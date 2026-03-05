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
SMODS.Atlas({key = 'ma_spectral', path = 'Spectral.png', px = 71, py = 95})

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
    if G.GAME.old_tags_num < #G.GAME.tags then --
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
    cost = 3,
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
        delay(0.5)
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
    end,

    use = function (self, card, area, copier)
        local now_hand, planet, smallest = nil, nil, 999999 --перебираем все руки и ищем наименее часто использованную
                                                            --(как показали тесты: если рук не разыгрывалось вообще, то даёт карты старшей карты,
                                                            --а если развгранное количество одинаковое - той что разыгрывалась последний раз)
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
            chance_up = 3,
            chance_down = 4,
            lvl = 2
        }
    },

    loc_vars = function (self, info_queue, card)
    end,

    use = function (self, card, area, copier)
        if pseudorandom('queensword') < card.ability.extra.chance_up / card.ability.extra.chance_down then --Перебираем все руки и берём рандомную, ур которой больше 2
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
            chanse = 5,
            chanse_add = 3
        }
    },

    loc_vars = function (self, info_queue, card)
    end,

    use = function (self, card, area, copier)
        if pseudorandom('kingsword') < G.GAME.probabilities.normal / card.ability.extra.chanse then --Тут мы просто выдаем с шансом черную дыру и с другим шансом создаем её негативную копию
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
            if pseudorandom('kingswordadd') < G.GAME.probabilities.normal / card.ability.extra.chanse_add then
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
        return true
    end

}

SMODS.Consumable{ --Cup
    set = 'Spectral',
    atlas = 'ma_spectral',
    key = 'cup',

    unlocked = false,
    check_for_unlock = function(self, args)
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
    end,

    use = function (self, card, area, copier)
        
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
        extra = 8
    },

    loc_vars = function (self, info_queue, card)
    end,

    use = function (self, card, area, copier)
        
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
        extra = 8
    },

    loc_vars = function (self, info_queue, card)
    end,

    use = function (self, card, area, copier)
        
    end,

    can_use = function()
        return true
    end

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
        extra = 8
    },

    loc_vars = function (self, info_queue, card)
    end,

    use = function (self, card, area, copier)
        
    end,

    can_use = function()
        return true
    end

}