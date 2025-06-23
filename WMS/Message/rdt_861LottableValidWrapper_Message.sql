-- rdt_861LottableValidWrapper
-- FCR-2519
execute rdt.rdtDropMsg 234251, 234300

execute rdt.rdtAddMsg 234251, 10, '234251 Valid SP Required',        'us_english', 861,   0, '234251 Valid SP Required'
execute rdt.rdtAddMsg 234252, 10, '234252 StorerKey Required',       'us_english', 861,   0, '234252 StorerKey Required'
execute rdt.rdtAddMsg 234253, 10, '234253 Valid SP Does Not Exist',  'us_english', 861,   0, '234253 Valid SP Does Not Exist'

SELECT * FROM rdt.rdtMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 234251 AND 234300