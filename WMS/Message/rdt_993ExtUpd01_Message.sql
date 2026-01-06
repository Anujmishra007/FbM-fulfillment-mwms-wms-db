-- rdt_993ExtUpd01
--242451 - 242500

execute rdt.rdtDropMsg 242451, 242500

execute rdt.rdtAddMsg 242451, 10, '242451^GetBOLSeqNoFailed',   'us_english', 993, 0, '242451: Failed to get BOL sequence number.'
execute rdt.rdtAddMsg 242452, 10, '242452^UpdOrderInfoFailed',  'us_english', 993, 0, '242452: Update OrderInfo failed.'

select * from rdt.rdtmsg (nolock) where message_id between 242451 and 242500
