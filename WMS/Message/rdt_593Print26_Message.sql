--rdt_593Print26
 exec rdt.rdtDropMsg 142551 , 142600	

execute rdt.rdtAddMsg 142551 ,10, '42551^Need Value',       'us_english',593
execute rdt.rdtAddMsg 142552 ,10, '42552^Inv OrderKey',     'us_english',593
execute rdt.rdtAddMsg 142553 ,10, '42553^NoPaperPrinter',   'us_english',593
execute rdt.rdtAddMsg 142554 ,10, '42554^NoLabelPrinter',   'us_english',593
execute rdt.rdtAddMsg 142555 ,10, '42555^Setup FilePath',   'us_english',593

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 142551 AND 142600	
