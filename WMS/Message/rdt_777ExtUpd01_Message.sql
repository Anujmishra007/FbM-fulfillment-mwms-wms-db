
--rdt_777ExtUpd01.sql
--FCR-9200

exec rdt.rdtdropmsg 251701, 251750

execute rdt.rdtAddMsg 251701, 10, '251701UpdPackInfoFail',       'us_english', 777, 0, '251701 Update PackInfo Failed'

select * from rdt.rdtmsg (nolock) where message_id between 251701 AND 251750