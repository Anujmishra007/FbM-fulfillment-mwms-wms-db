-- rdt_838PntShipLbl05
EXECUTE rdt.rdtDropMsg 225851  , 225900		

EXECUTE rdt.rdtAddMsg 225851, 10, '225851GetFilePathFail', 'us_english', 838
EXECUTE rdt.rdtAddMsg 225852, 10, '225852SubCldPrtFail  ', 'us_english', 838
EXECUTE rdt.rdtAddMsg 225853, 10, '225853PrinterNotExists ', 'us_english', 838
EXECUTE rdt.rdtAddMsg 225854, 10, '225854MissCldPrntID ', 'us_english', 838
EXECUTE rdt.rdtAddMsg 225855, 10, '225855Invalid Label Name', 'us_english', 838
EXECUTE rdt.rdtAddMsg 225856, 10, '225856Invalid Condition', 'us_english', 838
EXECUTE rdt.rdtAddMsg 225857, 10, '225857URLEncode Failure', 'us_english', 838
EXECUTE rdt.rdtAddMsg 225858, 10, '225858INS PrnJobFail', 'us_english', 838
EXECUTE rdt.rdtAddMsg 225859, 10, '225859Invalid ExternOrderkey', 'us_english', 838
EXECUTE rdt.rdtAddMsg 225860, 10, '225860Invalid RptDtl', 'us_english', 838


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 225851 AND 225900
