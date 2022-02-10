--rdt_629SuggestLoc01
execute rdt.rdtDropMsg 164901 , 164950

execute rdt.rdtAddMsg 164901, 10, '25551^No Suggest LOC',     'us_english', 629

select * from rdt.rdtmsg (nolock) where message_id between 164901 and 164950
