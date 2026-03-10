--rdt_605RcvCfm05_GetSuggestLoc
--260201 - 260250


rdt.rdtDropMsg 260201, 260250

execute rdt.rdtAddMsg 260201, 10, '260201^PAZoneMissing',      'us_english', 605
execute rdt.rdtAddMsg 260202, 10, '260202^NoLocFound',         'us_english', 605
execute rdt.rdtAddMsg 260203, 10, '260203^PAZoneMissing',      'us_english', 605
execute rdt.rdtAddMsg 260204, 10, '260204^NoLocFound',         'us_english', 605
execute rdt.rdtAddMsg 260205, 10, '260205^PAZoneMissing',      'us_english', 605
execute rdt.rdtAddMsg 260206, 10, '260206^NoLocFound',         'us_english', 605
execute rdt.rdtAddMsg 260207, 10, '260207^PAZoneMissing',      'us_english', 605
execute rdt.rdtAddMsg 260208, 10, '260208^NoLocFound',         'us_english', 605
execute rdt.rdtAddMsg 260209, 10, '260209^NoPALogicFound',     'us_english', 605

select * from rdt.rdtmsg (NOLOCK) where message_id between 260201 AND 260250

