--Message file
--execute rdt.rdtdropmsg
rdt.rdtDropMsg 230001, 230050

execute rdt.rdtAddMsg 230001  ,10   ,'230001^SN ady used '     ,'us_english'  ,838  ,0 ,'230001 - SN is already used'
execute rdt.rdtAddMsg 230002  ,10   ,'230002^GetKeyFail'       ,'us_english'  ,838  ,0 ,'230002 - Generate SerialNo Key Fail'
execute rdt.rdtAddMsg 230003  ,10   ,'230003^InsSerialNoFail'  ,'us_english'  ,838  ,0 ,'230003 - Insert SerialNo Fail'

SELECT * FROM RDT.RDTMSG WITH(NOLOCK) WHERE Message_ID BETWEEN 230001 AND 230050
