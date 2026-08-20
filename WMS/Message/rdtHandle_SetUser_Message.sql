--rdtHandle_SetUser
--execute rdt.rdtdropmsg 275451 - 275500
execute rdt.rdtDropMsg 275451, 275500

execute rdt.rdtAddMsg 275451, 10, '275451^SQLExceptionCaught', 'us_english', 0, 0, '275451: SQL exception caught, check rdtLog for details'

select * from rdt.rdtmsg (nolock) where message_id between 275451 and 275500
