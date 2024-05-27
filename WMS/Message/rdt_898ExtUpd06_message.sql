
--rdt_898ExtUpd05  
execute rdt.rdtdropmsg 215351, 215400		

execute rdt.rdtAddMsg 215351, 10, '215351^Add TransmitLog2 Fail', 'us_english', 898

select * from rdt.rdtmsg (nolock) where message_id between 215351 AND 215400