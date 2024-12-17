-- rdt_727Inquiry26
--UWP-28428
execute rdt.rdtDropMsg 231001, 231050

execute rdt.rdtAddMsg 231001, 10, '231001NeedDropID',          'us_english', 727
execute rdt.rdtAddMsg 231002, 10, '231002InvalidDropID',       'us_english', 727
execute rdt.rdtAddMsg 231003, 10, '231003NoWave',              'us_english', 727

SELECT * FROM rdt.rdtmsg WITH(NOLOCK) WHERE Message_ID BETWEEN 231001 AND 231050