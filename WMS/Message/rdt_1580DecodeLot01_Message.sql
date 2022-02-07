-- rdt_1580DecodeLot01
execute rdt.rdtDropMsg 162601, 162650

execute rdt.rdtAddMsg 162601, 10, '162601^WrongBatchNo ', 'us_english', 1580
execute rdt.rdtAddMsg 162602, 10, '62602L02-WrongFormat', 'us_english', 1580
execute rdt.rdtAddMsg 162603, 10, '62603WrongDateFormat', 'us_english', 1580
execute rdt.rdtAddMsg 162604, 10, '62604L02-WrongFormat', 'us_english', 1580
execute rdt.rdtAddMsg 162605, 10, '62605^L02 Required  ', 'us_english', 1580
execute rdt.rdtAddMsg 162606, 10, '62606^L03 Required  ', 'us_english', 1580
execute rdt.rdtAddMsg 162607, 10, '62607^L04 Required  ', 'us_english', 1580

SELECT TOP 10 * FROM rdt.rdtMsg (NOLOCK) WHERE message_id BETWEEN 162601 AND 162650
