
select * from rdt.rdtmsg with (nolock) where message_id between 154801 and 154850;

-- rdt_638ExtUpd02
execute rdt.rdtDropMsg 154801  , 154850

execute rdt.rdtaddmsg 154801, 10, '154801LineFinalized','us_english'
execute rdt.rdtaddmsg 154802, 10, '154802UpdRDFail','us_english'
execute rdt.rdtaddmsg 154803, 10, '154803UpdRFail','us_english'
