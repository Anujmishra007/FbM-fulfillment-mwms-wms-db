-- 268001 - 268050 FCR-12622 (NYE018)
-- rdt_1628ExtScn01

execute rdt.rdtDropMsg 268001 , 268050

execute rdt.rdtAddMsg 268001, 10, '268001^TOLOCRequired', 'us_english', 1628
execute rdt.rdtAddMsg 268002, 10, '268002^LOC Mismatch',  'us_english', 1628
execute rdt.rdtAddMsg 268003, 10, '268003^Invalid LOC',   'us_english', 1628
execute rdt.rdtAddMsg 268004, 10, '268004^Move Failed',   'us_english', 1628
execute rdt.rdtAddMsg 268005, 10, '268005^PD Update Fail', 'us_english', 1628

select * from rdt.rdtmsg (nolock) where message_id between 268001 AND 268050
