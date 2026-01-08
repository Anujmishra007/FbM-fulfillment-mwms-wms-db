--rdt_1837ExtScn01  (NYE018)
-- 255901 - 255950

execute rdt.rdtdropmsg 255901 , 255950

execute rdt.rdtAddMsg 255901, 10, '255901^OptionRequired',       'us_english',1837, 0, '255901: Option Required'
execute rdt.rdtAddMsg 255902, 10, '255902^InvalidOption',        'us_english',1837, 0, '255902: Invalid Option'

select * from rdt.rdtmsg (nolock) where message_id between 255901 and 255950