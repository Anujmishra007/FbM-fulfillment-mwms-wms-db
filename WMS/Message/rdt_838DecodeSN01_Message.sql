--rdt_838DecodeSN01
execute rdt.rdtdropmsg 144051 , 144100

execute rdt.rdtAddMsg 144051, 10, '44051^SrCnt NotMatch', 'us_english', 838
execute rdt.rdtAddMsg 144052, 10, '44052^SrCnt NotMatch', 'us_english', 838

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE MESSAGE_ID BETWEEN 144051 AND 144100	