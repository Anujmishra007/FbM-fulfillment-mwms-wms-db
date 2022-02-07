
-- rdt_840ExtDelPack01 
execute rdt.rdtDropMsg 59201 , 59250

execute rdt.rdtAddMsg 59201, 10, '59201^UPD PKDTL FAIL',    'us_english'
execute rdt.rdtAddMsg 59202, 10, '59202^GET TRK# FAIL',     'us_english'
execute rdt.rdtAddMsg 59203, 10, '59203^RELEASE  FAIL',     'us_english'
execute rdt.rdtAddMsg 59204, 10, '59204^ASSGN TRK# FAIL',   'us_english'
execute rdt.rdtAddMsg 59205, 10, '59205^REVERSE FAIL',      'us_english'

select * from rdt.rdtmsg (nolock) where message_id between 59201 and 59250
