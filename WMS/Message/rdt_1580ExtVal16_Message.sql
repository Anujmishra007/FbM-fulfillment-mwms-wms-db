--rdt_1580ExtVal16
execute rdt.rdtDropMsg 151501 , 151550

execute rdt.rdtAddMsg 151501, 10, '51501^UCC NOT EXISTS',    'us_english', 1580
execute rdt.rdtAddMsg 151502, 10, '51502^SKU NOT IN UCC',    'us_english', 1580

select * from rdt.rdtmsg (nolock) where message_id between 151501 AND 151550