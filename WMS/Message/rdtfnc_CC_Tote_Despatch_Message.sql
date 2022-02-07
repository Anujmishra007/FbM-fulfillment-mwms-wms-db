--rdtfnc_rdtfnc_CC_Tote_Despatch
--execute rdt.rdtdropmsg 72241, 72265

execute rdt.rdtAddMsg '72241', 10, '72241^Tote No Req',      'us_english'
execute rdt.rdtAddMsg '72242', 10, '72242^INV TOTENO LEN',   'us_english'
execute rdt.rdtAddMsg '72243', 10, '72243^LBL Not Print',    'us_english'
execute rdt.rdtAddMsg '72244', 10, '72244^Mfes Not Print',   'us_english'
execute rdt.rdtAddMsg '72245', 10, '72245^Tote not C&C',     'us_english'
execute rdt.rdtAddMsg '72246', 10, '72246^ORD Not Shipped',  'us_english'
execute rdt.rdtAddMsg '72247', 10, '72247^POD Not Exists',   'us_english'
execute rdt.rdtAddMsg '72248', 10, '72248^POD Finalized',    'us_english'
execute rdt.rdtAddMsg '72249', 10, '72249^Inv POD Status',   'us_english'
execute rdt.rdtAddMsg '72250', 10, '72250^Conf POD Fail',    'us_english'
execute rdt.rdtAddMsg '72251', 10, '72251^DLT TOTE FAIL',    'us_english'
execute rdt.rdtAddMsg '72252', 10, '72252^DLT TOTE FAIL',    'us_english'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 72241 AND 72265