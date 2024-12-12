--Message file
execute rdt.rdtDropMsg 218030, 218034

execute rdt.rdtAddMsg 218030, 10, '218030Date can''t be future',     'us_english', 600, 0, '218030 Date can''t be future'
execute rdt.rdtAddMsg 218031, 10, '218031Please check date',         'us_english', 600, 0, '218031 Please check date'
execute rdt.rdtAddMsg 218032, 10, '218032Enter numeric value',       'us_english', 600, 0, '218032 Enter numeric value'
execute rdt.rdtAddMsg 218033, 10, '218033No batch no required',      'us_english', 600, 0, '218033 No batch no required'
execute rdt.rdtAddMsg 218034, 10, '218034Incorrect batch no',        'us_english', 600, 0, '218034 Incorrect batch no'

SELECT * FROM RDT.RDTMSG WITH(NOLOCK) WHERE Message_ID BETWEEN 218030 AND 218034