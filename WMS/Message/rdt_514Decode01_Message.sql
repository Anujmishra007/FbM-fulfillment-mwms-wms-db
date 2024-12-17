
-- rdt_514Decode01_Message
execute rdt.rdtDropMsg 227151, 227200

execute rdt.rdtAddMsg 227151  ,10 ,'227151 Invalid ID','us_english' ,514  ,0 ,N'227151 Invalid ID(25 digit)'
execute rdt.rdtAddMsg 227152  ,10 ,'227152 Invalid UCC','us_english' ,514  ,0 ,N'227152 Invalid UCC(40 digit)'

select * from rdt.rdtmsg (nolock) where message_id between 227151 AND 227200

