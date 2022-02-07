--rdt_593Print23
 exec rdt.rdtDropMsg 130501 , 130550	

execute rdt.rdtAddMsg 130501 ,10, '30501^Need Value',       'us_english',593
execute rdt.rdtAddMsg 130502 ,10, '30502^Inv OrderKey',     'us_english',593
execute rdt.rdtAddMsg 130503 ,10, '30503^Inv Track #',      'us_english',593
execute rdt.rdtAddMsg 130504 ,10, '30504^No Record',        'us_english',593

--WMS9955
execute rdt.rdtAddMsg 130505 ,10, '30505^InvalidLabelNo',   'us_english',593

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 130501 AND 130550	
