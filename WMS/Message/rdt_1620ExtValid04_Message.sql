--rdt_1620ExtValid04
execute rdt.rdtdropmsg 121251 , 121300

execute rdt.rdtAddMsg 121251, 10, '21251^CANNOT MIX ORD',  'us_english', 1620
execute rdt.rdtAddMsg 121252, 10, '21252^BOX MIX COO',     'us_english', 1620
execute rdt.rdtAddMsg 121253, 10, '21253^BOX MIX SKU',     'us_english', 1620
execute rdt.rdtAddMsg 121254, 10, '21254^BOX MIX STYLE',   'us_english', 1620
execute rdt.rdtAddMsg 121255, 10, '21255^BOX MIX COLOR',   'us_english', 1620

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 121251 AND 121300

