--rdt_830SwapIDSP01
rdt.rdtDropMsg 168501  , 168550	

execute rdt.rdtAddMsg 168501, 10, '168501Differentlot',    'us_english', 830
execute rdt.rdtAddMsg 168503, 10, '168503UpdPDFail',   'us_english', 830
execute rdt.rdtAddMsg 168502, 10, '168502SuggestIDFail',   'us_english', 830

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 168501 AND 168550