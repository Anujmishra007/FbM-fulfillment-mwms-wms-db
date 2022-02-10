--rdt_840ExtUpd07
exec rdt.rdtDropMsg 135751 , 135800

execute rdt.rdtAddMsg 135751, 10, '35751^Set DropID Err',   'us_english', 840
execute rdt.rdtAddMsg 135752, 10, '35752^No PKSlip',        'us_english', 840
execute rdt.rdtAddMsg 135753, 10, '35753^No OrderKey',      'us_english', 840
execute rdt.rdtAddMsg 135754, 10, '35754^Upd OdHdr Fail',   'us_english', 840
execute rdt.rdtAddMsg 135755, 10, '35755^Upd OdDtl Fail',   'us_english', 840
execute rdt.rdtAddMsg 135756, 10, '35756^Upd LpDtl Fail',   'us_english', 840
execute rdt.rdtAddMsg 135757, 10, '35757^nspGetRightErr',   'us_english', 840
execute rdt.rdtAddMsg 135758, 10, '35758^GenTLog3 Fail',    'us_english', 840

select * from rdt.rdtmsg (nolock) where message_id between 135751 and 135800



