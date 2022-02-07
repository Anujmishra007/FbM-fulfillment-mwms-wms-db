

select * from rdt.rdtmsg with (nolock) where message_id between 154301 and 154350;

-- rdt_638RcvCfm02
execute rdt.rdtDropMsg 154301  , 154350

execute rdt.rdtaddmsg 154301, 10, '154301^UpdRDFail','us_english'

