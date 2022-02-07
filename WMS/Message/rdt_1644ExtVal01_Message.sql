--rdt_1644ExtVal01
execute rdt.rdtdropmsg 136001 , 136050

execute rdt.rdtAddMsg 136001, 10, '36001^Nothing 2 Scan',   'us_english', 1644
execute rdt.rdtAddMsg 136002, 10, '36002^Duplicate CaseID', 'us_english', 1644
execute rdt.rdtAddMsg 136003, 10, '36003^Duplicate Serial', 'us_english', 1644
execute rdt.rdtAddMsg 136004, 10, '36004^SrCntNotMatch',    'us_english', 1644
execute rdt.rdtAddMsg 136005, 10, '36005^SrLenNotMatch',    'us_english', 1644
execute rdt.rdtAddMsg 136006, 10, '36006^SKU NotExists',    'us_english', 1644
execute rdt.rdtAddMsg 136007, 10, '36007^Over Scanned',     'us_english', 1644

select * from rdt.rdtmsg (nolock) where message_id between 136001 AND 136050
