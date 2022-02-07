--rdtfnc_Tote_Case_Inquiry
--execute rdt.rdtdropmsg 69616, 69940

execute rdt.rdtAddMsg 69916, 10, '69916^Option req',     'us_english'
execute rdt.rdtAddMsg 69917, 10, '69917^Invalid Option', 'us_english'
execute rdt.rdtAddMsg 69918, 10, '69918^TOTE/CASE# req', 'us_english'
execute rdt.rdtAddMsg 69919, 10, '69919^Inv TOTE/CASE',  'us_english'
execute rdt.rdtAddMsg 69920, 10, '69920^Invalid TOTE',   'us_english'
execute rdt.rdtAddMsg 69921, 10, '69921^Invalid CASE',   'us_english'

-- SOS268332
execute rdt.rdtAddMsg 69922, 10, '69922^Invalid CASE',   'us_english'
execute rdt.rdtAddMsg 69923, 10, '69923^Invalid OPT',    'us_english'

select * from rdt.rdtmsg (nolock) where message_id between 69916 and 69940