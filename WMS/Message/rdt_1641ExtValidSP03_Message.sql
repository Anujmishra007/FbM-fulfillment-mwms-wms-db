-- rdt_1641ExtValidSP03
execute rdt.rdtDropMsg 97351 , 97400

execute rdt.rdtAddMsg 97351, 10, '97351^NO ORDERKEY', 'us_english'
execute rdt.rdtAddMsg 97356, 10, '97356^INVALID DATE','us_english'

-- Long error msg

-- 97352 Invalid Column Name
-- 97353 Invalid Column Type
-- 97354 Value Not Match
-- 97355 Column Is Required But Now Is Empty

select * from rdt.rdtmsg (nolock) where message_id between 97351 and 97400