--rdt_1620ExtValid01
--execute rdt.rdtdropmsg 93701 , 93750

execute rdt.rdtAddMsg 93701, 10, '93701^BOX MIX COO',     'us_english', 1620
execute rdt.rdtAddMsg 93702, 10, '93702^BOX MIX SKU',     'us_english', 1620
execute rdt.rdtAddMsg 93703, 10, '93703^BOX MIX STYLE',   'us_english', 1620
execute rdt.rdtAddMsg 93704, 10, '93704^BOX MIX COLOR',   'us_english', 1620

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 93701 AND 93750

