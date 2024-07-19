
--FCR-392
exec rdt.rdtdropmsg 217501 , 217550

execute rdt.rdtAddMsg 217501, 10, '217501NothingPicked', 'us_english', 838
execute rdt.rdtAddMsg 217502, 10, '217502PackMoreThenPick', 'us_english', 838
execute rdt.rdtAddMsg 217503, 10, '217503InvalidOption', 'us_english', 838


select * from rdt.rdtmsg (nolock) where message_id between 217501 AND 217550