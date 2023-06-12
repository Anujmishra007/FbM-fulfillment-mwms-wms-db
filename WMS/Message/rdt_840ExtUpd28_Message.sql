-- rdt_840ExtUpd28
execute rdt.rdtdropmsg 202251 , 202300

execute rdt.rdtAddMsg 202251, 10, '202251 NO TRACK NO  ',   'us_english', 840
execute rdt.rdtAddMsg 202252, 10, '202252 INV TRACK NO ',   'us_english', 840
execute rdt.rdtAddMsg 202253, 10, '202253 Upd Track Err',   'us_english', 840
execute rdt.rdtAddMsg 202254, 10, '202254 UPD PACKIF Er',   'us_english', 840
execute rdt.rdtAddMsg 202255, 10, '202255 NO TRACKING #',   'us_english', 840
execute rdt.rdtAddMsg 202256, 10, '202256 ASS TRACK# Er',   'us_english', 840
execute rdt.rdtAddMsg 202257, 10, '202257 REL TRACK# Er',   'us_english', 840
execute rdt.rdtAddMsg 202258, 10, '202258 UPD Orders Er',   'us_english', 840
execute rdt.rdtAddMsg 202259, 10, '202259 UPD PKDTL Err',   'us_english', 840
execute rdt.rdtAddMsg 202260, 10, '202260 UPD PKDTL Err',   'us_english', 840

select * from rdt.rdtmsg (nolock) where message_id between 202251 AND 202300