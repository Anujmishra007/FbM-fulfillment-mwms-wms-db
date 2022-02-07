

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN '178101' AND '178150'


--rdt_839ExtValidSP09
EXEC rdt.rdtDropMsg 178101, 178150

execute rdt.rdtAddMsg 178001, 10, '178101Invalid Format',   'us_english', 839
execute rdt.rdtAddMsg 178002, 10, '178102 DropID In Use',   'us_english', 839
execute rdt.rdtAddMsg 178003, 10, '178103 DropID In Use',   'us_english', 839
