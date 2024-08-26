-- rdt_593Print36_message
execute rdt.rdtDropMsg 217101 , 217150			

execute rdt.rdtAddMsg 217101, 10, '217101MissExtOrd', 'us_english', 593
execute rdt.rdtAddMsg 217102, 10, '217102OrdNotFound', 'us_english', 593
execute rdt.rdtAddMsg 217103, 10, '217103NotB2COrd', 'us_english', 593
execute rdt.rdtAddMsg 217104, 10, '217104MissRptInCode', 'us_english', 593
execute rdt.rdtAddMsg 217105, 10, '217105RptNotFound', 'us_english', 593
execute rdt.rdtAddMsg 217106, 10, '217106PrntNotExist', 'us_english', 593
execute rdt.rdtAddMsg 217107, 10, '217107MissCldPrntID', 'us_english', 593
execute rdt.rdtAddMsg 217108, 10, '217108MissWebSrcCfg', 'us_english', 593
execute rdt.rdtAddMsg 217109, 10, '217109FilePathEmpty', 'us_english', 593
execute rdt.rdtAddMsg 217110, 10, '217110InsPrnJobFail', 'us_english', 593
execute rdt.rdtAddMsg 217111, 10, '217111SubCldPrnFail', 'us_english', 593
execute rdt.rdtAddMsg 217112, 10, '217112NoRptPrnt', 'us_english', 593


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 217101 AND 217150
