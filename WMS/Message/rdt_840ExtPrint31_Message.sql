-- rdt_840ExtPrint31
EXECUTE rdt.rdtDropMsg 226851  , 226900		

EXECUTE rdt.rdtAddMsg 226851, 10, '226851GetFilePathFail', 'us_english', 840, 0, '226851 Get File Path Failure'
EXECUTE rdt.rdtAddMsg 226852, 10, '226852SubCldPrtFail  ', 'us_english', 840, 0, '226852 Submit Cloud Print Task Failure'
EXECUTE rdt.rdtAddMsg 226853, 10, '226853PrinterNotExist', 'us_english', 840, 0, '226853 Printer is not exist.'
EXECUTE rdt.rdtAddMsg 226854, 10, '226854MissCldPrntID  ', 'us_english', 840, 0, '226854 Miss Cloud Printer ID'
EXECUTE rdt.rdtAddMsg 226855, 10, '226855Invalid LblName', 'us_english', 840, 0, '226855 Invalid Label Name'
EXECUTE rdt.rdtAddMsg 226856, 10, '226856Invalid Conditi', 'us_english', 840, 0, '226856 Invalid Conditition'
EXECUTE rdt.rdtAddMsg 226857, 10, '226857URLEncode Fail ', 'us_english', 840, 0, '226857 URLEncode Failure '
EXECUTE rdt.rdtAddMsg 226858, 10, '226858INS PrnJobFail ', 'us_english', 840, 0, '226858 Insert Print Job Fail'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 226851 AND 226900