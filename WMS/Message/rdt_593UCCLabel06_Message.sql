-- rdt_593UCCLabel06
execute rdt.rdtDropMsg 164501, 164550

execute rdt.rdtAddMsg 164501, 10, '164501^Need ID      ', 'us_english', 593
execute rdt.rdtAddMsg 164502, 10, '164502Invalid dropid', 'us_english', 593
execute rdt.rdtAddMsg 164503, 10, '164503^CLOSED       ', 'us_english', 593
execute rdt.rdtAddMsg 164504, 10, '164504InsertTL3 Fail', 'us_english', 593

select * from rdt.rdtMsg (nolock) where message_id between 164501 and 164550
