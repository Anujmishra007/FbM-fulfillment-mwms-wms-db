--rdt_1580DecodeSN05
execute rdt.rdtDropMsg 277051 , 277100

execute rdt.rdtAddMsg 277051, 10, '277051^InvalidSerialN', 'us_english', 1580, 0, '277051 Invalid SerialNo'

SELECT * FROM RDT.RDTMSG WITH (NOLOCK) WHERE MESSAGE_ID BETWEEN 277051 AND 277100
