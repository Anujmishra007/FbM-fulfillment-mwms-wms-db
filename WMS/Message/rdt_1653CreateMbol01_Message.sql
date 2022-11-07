--rdt_1653CreateMbol01
exec rdt.rdtDropMsg 191351 , 191400

execute rdt.rdtAddMsg 191351, 10, '191351 Del PltDtl Er',   'us_english', 1653
execute rdt.rdtAddMsg 191352, 10, '191352 Del PltHdr Er',   'us_english', 1653
execute rdt.rdtAddMsg 191353, 10, '191353INS PalletFail',   'us_english', 1653
execute rdt.rdtAddMsg 191354, 10, '191354 INS PLDtl Err',   'us_english', 1653
execute rdt.rdtAddMsg 191355, 10, '191355 GetKey Fail  ',   'us_english', 1653
execute rdt.rdtAddMsg 191356, 10, '191356 INS MBOL Fail',   'us_english', 1653
execute rdt.rdtAddMsg 191357, 10, '191357 MBOL Shipped ',   'us_english', 1653
execute rdt.rdtAddMsg 191358, 10, '191358 INS MBDtl Err',   'us_english', 1653

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 191351 AND 191400

