-- rdt_593Print36_message
execute rdt.rdtDropMsg 217201 , 217250			

execute rdt.rdtAddMsg 217201, 10, '217201MissExtOrd', 'us_english', 593
execute rdt.rdtAddMsg 217202, 10, '217202OrdNotFound', 'us_english', 593
execute rdt.rdtAddMsg 217203, 10, '217203NotB2COrd', 'us_english', 593
execute rdt.rdtAddMsg 217204, 10, '217204MissRptInCode', 'us_english', 593
execute rdt.rdtAddMsg 217205, 10, '217205RptNotFound', 'us_english', 593
execute rdt.rdtAddMsg 217206, 10, '217206PrntNotExist', 'us_english', 593
execute rdt.rdtAddMsg 217207, 10, '217207MissCldPrntID', 'us_english', 593
execute rdt.rdtAddMsg 217208, 10, '217208MissWebSrcCfg', 'us_english', 593
execute rdt.rdtAddMsg 217209, 10, '217209FilePathEmpty', 'us_english', 593
execute rdt.rdtAddMsg 217210, 10, '217210InsPrnJobFail', 'us_english', 593
execute rdt.rdtAddMsg 217211, 10, '217211SubCldPrnFail', 'us_english', 593
execute rdt.rdtAddMsg 217212, 10, '217212NoRptPrnt', 'us_english', 593


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 217201 AND 217250
