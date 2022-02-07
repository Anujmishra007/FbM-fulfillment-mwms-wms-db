--rdt_593Print25
execute rdt.rdtDropMsg 141401 , 141450

execute rdt.rdtAddMsg 141401, 10, '41401^Need Value',    'us_english'
execute rdt.rdtAddMsg 141402, 10, '41402^Invalid Label', 'us_english'
execute rdt.rdtAddMsg 141403, 10, '41403^No PDF File',   'us_english'
execute rdt.rdtAddMsg 141404, 10, '41404^No Print Path', 'us_english'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 141401 AND 141450