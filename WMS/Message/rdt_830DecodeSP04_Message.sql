

-- rdt_830DecodeSP04_Message
execute rdt.rdtDropMsg 226951, 227000

execute rdt.rdtAddMsg 226951, 10 ,'226951 Invalid ID','us_english' ,830  ,0 ,N'226951 Invalid ID(25 digit)'
execute rdt.rdtAddMsg 226952, 10 ,'226952 Invalid ID','us_english' ,830  ,0 ,N'226952 Invalid ID(25 digit)'

select * from rdt.rdtmsg (nolock) where message_id between 226951 AND 227000

GO
