

-- rdt_922DecodeSP01_Message
execute rdt.rdtDropMsg 227001, 227050

execute rdt.rdtAddMsg 227001  ,10 ,'227001 Invalid UCC','us_english' ,922  ,0 ,N'227001 Invalid UCC(40 digit)'

select * from rdt.rdtmsg (nolock) where message_id between 227001 AND 227050

