

-- rdt_512DecodeSP01_Message
execute rdt.rdtDropMsg 226401, 226450

execute rdt.rdtAddMsg 226401, 10, '226401 Invalid ID', 'us_english', 512, 0, N'226401 Invalid ID(25 digit)'

execute rdt.rdtDropMsg 226751, 226800

execute rdt.rdtAddMsg 226751, 10, '226751 Update UDF01 Fail', 'us_english', 512, 0, N'226751 Invalid ID(25 digit)'

select * from rdt.rdtmsg (nolock) where message_id between 226401 AND 226450

select * from rdt.rdtmsg (nolock) where message_id between 226751 AND 226800


