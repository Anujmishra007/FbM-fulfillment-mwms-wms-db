-- rdt_593PrintCldFile03_message
--UWP-32538
execute rdt.rdtDropMsg 236101 , 236150		

execute rdt.rdtAddMsg 236101, 10, '236101NeedOrderKey',              'us_english', 593, 0, '236101 Need OrderKey'
execute rdt.rdtAddMsg 236102, 10, '236102InvalidMBOLKEY',            'us_english', 593, 0, '236102 Invalid MBOLKEY'
execute rdt.rdtAddMsg 236103, 10, '236103NeedExtOrderKey',           'us_english', 593, 0, '236103 Need ExtOrderKey'
execute rdt.rdtAddMsg 236104, 10, '236104FETCHCODEFAILED',           'us_english', 593, 0, '236104 FETCH CODE FAILED'
execute rdt.rdtAddMsg 236105, 10, '236105Invalid Condition',         'us_english', 593, 0, '236105 Invalid Condition'
execute rdt.rdtAddMsg 236106, 10, '236106MissWebSrvc',               'us_english', 593, 0, '236106 Miss Web Service'
execute rdt.rdtAddMsg 236107, 10, '236107FailedToEncryptFilePath',   'us_english', 593, 0, '236107 Failed to encrypt file path'
execute rdt.rdtAddMsg 236108, 10, '236108ReportNotExist',            'us_english', 593, 0, '236108 Report Not Exist'
execute rdt.rdtAddMsg 236109, 10, '236109PrinterNotExists',          'us_english', 593, 0, '236109 Printer Not Exists'
execute rdt.rdtAddMsg 236110, 10, '236110MissCldPrntID',             'us_english', 593, 0, '236110 Miss Cloud Printer ID'
execute rdt.rdtAddMsg 236111, 10, '236111InsPrnJobFail',             'us_english', 593, 0, '236111 Insert PrintJob Fail'
execute rdt.rdtAddMsg 236112, 10, '236112SubCldPrtFail',             'us_english', 593, 0, '236112 Submit Cloud PrintJob Fail'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 236101 AND 236150