-- rdt_608ExtUpd10
execute rdt.rdtDropMsg 162451, 162500

execute rdt.rdtAddMsg 162451, 10, '62451OverRec-RECType', 'us_english', 608
execute rdt.rdtAddMsg 162452, 10, '162452OverRec-ToLoc ', 'us_english', 608
execute rdt.rdtAddMsg 162453, 10, '162453LocNotInCodeLK', 'us_english', 608

select top 10 * from rdt.rdtMsg (nolock) where message_id between 162451 and 162500
