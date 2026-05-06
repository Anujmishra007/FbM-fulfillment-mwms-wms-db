--rdt_830ExtUpd03HRP

execute rdt.rdtdropmsg  218390
execute rdt.rdtdropmsg  218391

execute rdt.rdtAddMsg 218390, 10, '218390 Insert into TRANSMITLOG3 Failed. (rdt_830ExtUpd03HRP)',  'us_english', 830
execute rdt.rdtAddMsg 218391, 10, '218391 Insert into TRANSMITLOG3 Failed. (rdt_830ExtUpd03HRP)',  'us_english', 830



select * from rdt.rdtmsg (nolock) where message_ID in ('218390', '218391')