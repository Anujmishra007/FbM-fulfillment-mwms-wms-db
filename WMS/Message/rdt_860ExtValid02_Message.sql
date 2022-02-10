--rdt_860ExtValid02
exec rdt.rdtDropMsg 122051 , 122100

execute rdt.rdtAddMsg 122051, 10, '22051^Diff Pallet',   'us_english', 860
execute rdt.rdtAddMsg 122052, 10, '22052^L01 Not Match', 'us_english', 860
execute rdt.rdtAddMsg 122053, 10, '22053^L05 Not Match', 'us_english', 860
execute rdt.rdtAddMsg 122054, 10, '22054^L06 Not Match', 'us_english', 860
execute rdt.rdtAddMsg 122055, 10, '22055^L07 Not Match', 'us_english', 860
execute rdt.rdtAddMsg 122056, 10, '22056^L08 Not Match', 'us_english', 860
execute rdt.rdtAddMsg 122057, 10, '22057^L12 Not Match', 'us_english', 860


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 122051 AND 122100
