-- rdt_513SuggestLOC03
exec rdt.rdtDropMsg 112351 , 112400

execute rdt.rdtAddMsg 112351, 10, '12351^NO PA ZONE',       'us_english', 513

select * from rdt.rdtmsg (nolock) where message_id between 112351 AND 112400