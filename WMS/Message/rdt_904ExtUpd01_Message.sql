-- rdt_904ExtUpd01
execute rdt.rdtDropMsg 103201 , 103250

execute rdt.rdtAddMsg 103201, 10, '03201^Ins PPA Fail',    'us_english'
execute rdt.rdtAddMsg 103202, 10, '03202^Ins PPA Fail',    'us_english'
execute rdt.rdtAddMsg 103203, 10, '03203^Ins PPA Fail',    'us_english'
execute rdt.rdtAddMsg 103204, 10, '03204^Ins PPA Fail',    'us_english'
execute rdt.rdtAddMsg 103205, 10, '03205^Ins PPA Fail',    'us_english'

select * from rdt.rdtmsg (nolock) where message_id between 103201 and 103250