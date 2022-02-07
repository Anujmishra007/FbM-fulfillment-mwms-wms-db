--rdt_628Inquiry04
rdt.rdtDropMsg 140351 , 140400

execute rdt.rdtAddMsg 140351, 10, '40351^No record',      'us_english', 628
execute rdt.rdtAddMsg 140352, 10, '40352^No more record', 'us_english', 628

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 140351 AND 140400