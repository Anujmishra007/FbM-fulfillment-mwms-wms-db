-- rdtfnc_SerialNo_Inquiry
exec rdt.rdtDropMsg 117601 , 117650

execute rdt.rdtAddMsg 117601, 10, '17601^SerialNoReq',   'us_english'
execute rdt.rdtAddMsg 117602, 10, '17602^SRNoNotExist',  'us_english'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 117601 AND 117650
