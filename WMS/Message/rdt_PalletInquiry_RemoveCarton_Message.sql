--rdt_PalletInquiry_RemoveCarton
exec rdt.rdtDropMsg 191751 , 191800

execute rdt.rdtAddMsg 191751, 10, '191751Del PltDtl Err',   'us_english', 1667
execute rdt.rdtAddMsg 191752, 10, '191752Del PltDtl Err',   'us_english', 1667
execute rdt.rdtAddMsg 191753, 10, '191753Del PltHdr Err',   'us_english', 1667
execute rdt.rdtAddMsg 191754, 10, '191754Del PltHdr Err',   'us_english', 1667
execute rdt.rdtAddMsg 191755, 10, '191755Del PltHdr Err',   'us_english', 1667
execute rdt.rdtAddMsg 191756, 10, '191756Del PltHdr Err',   'us_english', 1667
execute rdt.rdtAddMsg 191757, 10, '191757Del PltDtl Err',   'us_english', 1667
execute rdt.rdtAddMsg 191758, 10, '191758Del PltDtl Err',   'us_english', 1667
execute rdt.rdtAddMsg 191759, 10, '191759Del PltHdr Err',   'us_english', 1667
execute rdt.rdtAddMsg 191760, 10, '191760 Del MBDtl Err',   'us_english', 1667
execute rdt.rdtAddMsg 191761, 10, '191761 Del MBHdr Err',   'us_english', 1667


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 191751 AND 191800

