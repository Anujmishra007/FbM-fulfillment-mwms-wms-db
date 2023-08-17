--rdt_1768ExtUpd01
exec rdt.rdtDropMsg 204601 , 204650

execute rdt.rdtAddMsg 204601, 10, '204601 Finalize Err ',   'us_english', 1768

select * from rdt.rdtmsg (nolock) where message_id BETWEEN 204601 AND 204650



