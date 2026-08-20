--rdtInsRDTLog
--execute rdt.rdtdropmsg 278151 - 278200
execute rdt.rdtDropMsg 278151, 278200

execute rdt.rdtAddMsg 278151, 10, '278151^MobileNotFound',  'us_english', 0, 0, '278151: Mobile not found in RDTMOBREC'
execute rdt.rdtAddMsg 278152, 10, '278152^InsertFailed',    'us_english', 0, 0, '278152: Failed to insert into rdtLog'
execute rdt.rdtAddMsg 278153, 10, '278153^UnexpectedError', 'us_english', 0, 0, '278153: Unexpected error in rdtInsRDTLog'

select * from rdt.rdtmsg (nolock) where message_id between 278151 and 278200
