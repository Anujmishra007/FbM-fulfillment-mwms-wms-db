--rdt_593Print29
 exec rdt.rdtDropMsg 158901 , 158950	

execute rdt.rdtAddMsg 158901 ,10, '58901^Need Value',       'us_english',593
execute rdt.rdtAddMsg 158902 ,10, '58902^Inv OrderKey',     'us_english',593
execute rdt.rdtAddMsg 158903 ,10, '58903^NoPaperPrinter',   'us_english',593
execute rdt.rdtAddMsg 158904 ,10, '58904^NoLabelPrinter',   'us_english',593
execute rdt.rdtAddMsg 158905 ,10, '58905^Setup FilePath',   'us_english',593

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 158901 AND 158950	
