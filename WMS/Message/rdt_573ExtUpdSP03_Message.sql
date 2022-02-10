--rdt_573ExtUpdSP03
exec rdt.rdtDropMsg 134251 , 134300

execute rdt.rdtAddMsg 134251 ,10, '34251^UpdRcptDetFail',   'us_english',573


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 134251 AND 134300
