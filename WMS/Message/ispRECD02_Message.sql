--ispRECD02
exec rdt.rdtDropMsg 118101 , 118150


execute rdt.rdtAddMsg 118101, 10, '18101^MULTI LOT01',   'us_english', 1581
execute rdt.rdtAddMsg 118102, 10, '18102^PO DUPLICATE',  'us_english', 1581
execute rdt.rdtAddMsg 118103, 10, '18103^UPD RCVD FAIL', 'us_english', 1581

select * from rdt.rdtmsg (nolock) where message_id between 118101 AND 118150



