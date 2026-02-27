--rdt_838ExtScn05_Message
--FCR-4325
EXEC rdt.rdtdropmsg 253201 , 253250

EXECUTE rdt.rdtAddMsg 253201, 10, '253201 DropIDNotExists',     'us_english', 838, 0, '253201 DropIDNotExists'
EXECUTE rdt.rdtAddMsg 253202, 10, '253202 InvalidOption',     'us_english', 838, 0, '253202 InvalidOption'



