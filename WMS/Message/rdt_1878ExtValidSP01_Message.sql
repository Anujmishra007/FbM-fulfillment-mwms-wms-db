--rdt_1878ExtValidSP01
--execute rdt.rdtdropmsg 261151 - 261200
execute rdt.rdtDropMsg 261151, 261200

execute rdt.rdtAddMsg 261151 ,10, '261151^IDExists',            'us_english', 1878, 0, '261151: Pallet already in use.'
execute rdt.rdtAddMsg 261152 ,10, '261152^Lottable01Mismatch',  'us_english', 1878, 0, '261152: Lottable01 Mismatch'
execute rdt.rdtAddMsg 261153 ,10, '261153^MissingMONOType',     'us_english', 1878, 0, '261153: Missing MONO Type'

select * from rdt.rdtmsg (nolock) where message_id between 261151 and 261200