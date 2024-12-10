
-- rdt_521Decode01_Message
execute rdt.rdtDropMsg 227101, 227150

execute rdt.rdtAddMsg 227101  ,10 ,'227101 Invalid ID','us_english' ,523  ,0 ,N'227101 Invalid ID(25 digit)'
execute rdt.rdtAddMsg 227102  ,10 ,'227102 Invalid UCC','us_english' ,523  ,0 ,N'227102 Invalid UCC(40 digit)'

select * from rdt.rdtmsg (nolock) where message_id between 227101 AND 227150

