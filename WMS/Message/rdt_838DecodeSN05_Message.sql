--rdt_838DecodeSN05
execute rdt.rdtdropmsg 277101 , 277150

execute rdt.rdtAddMsg 277101, 10, '277101^InvalidSerialN', 'us_english', 838, 0, '277101 Invalid SerialNo'

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE MESSAGE_ID BETWEEN 277101 AND 277150
