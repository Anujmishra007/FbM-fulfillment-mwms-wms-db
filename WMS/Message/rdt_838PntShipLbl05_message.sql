-- rdt_838PntShipLbl05
EXECUTE rdt.rdtDropMsg 225851  , 225900		

EXECUTE rdt.rdtAddMsg 225851, 10, '225851GetFilePathFail', 'us_english', 838, 0, '225851 Get File Path Failure'
EXECUTE rdt.rdtAddMsg 225852, 10, '225852SubCldPrtFail  ', 'us_english', 838, 0, '225852 Submit Cloud Print Task Failure'
EXECUTE rdt.rdtAddMsg 225853, 10, '225853PrinterNotExist', 'us_english', 838, 0, '225853 Printer is not exist.'
EXECUTE rdt.rdtAddMsg 225854, 10, '225854MissCldPrntID  ', 'us_english', 838, 0, '225854 Miss Cloud Printer ID'
EXECUTE rdt.rdtAddMsg 225855, 10, '225855Invalid LblName', 'us_english', 838, 0, '225855 Invalid Label Name'
EXECUTE rdt.rdtAddMsg 225856, 10, '225856Invalid Conditi', 'us_english', 838, 0, '225856 Invalid Conditition'
EXECUTE rdt.rdtAddMsg 225857, 10, '225857URLEncode Fail ', 'us_english', 838, 0, '225857 URLEncode Failure '
EXECUTE rdt.rdtAddMsg 225858, 10, '225858INS PrnJobFail ', 'us_english', 838, 0, '225858 Insert Print Job Fail'
EXECUTE rdt.rdtAddMsg 225859, 10, '225859InvalidExOrdkey', 'us_english', 838, 0, '225859 Invalid ExternOrderkey'
EXECUTE rdt.rdtAddMsg 225860, 10, '225860Invalid RptDtl ', 'us_english', 838, 0, '225860 Invalid Report Detail'
EXECUTE rdt.rdtAddMsg 225861, 10, '225861EncryptFileFail', 'us_english', 838, 0, '225861 FilePath Encryption Failure'
EXECUTE rdt.rdtAddMsg 225862, 10, '225862MissWebSrvc    ', 'us_english', 838, 0, '225862 Missing Web Service URL'
EXECUTE rdt.rdtAddMsg 225863, 10, '225863ReportNotSetup ', 'us_english', 838, 0, '225863 Report is not setup'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 225851 AND 225900
