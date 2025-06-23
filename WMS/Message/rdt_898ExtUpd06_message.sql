
--rdt_898ExtUpd06
--FCR236
execute rdt.rdtdropmsg 215351, 215400		

execute rdt.rdtAddMsg 215351, 10, '215351AddTranLogFail', 'us_english', 898, 0, '215351^Add TransmitLog2 Fail'
execute rdt.rdtAddMsg 215352, 10, '215352^Finalize Fail', 'us_english', 898

select * from rdt.rdtmsg (nolock) where message_id between 215351 AND 215400