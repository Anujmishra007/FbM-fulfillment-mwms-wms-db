--rdt_840ExtUpd16
exec rdt.rdtDropMsg 176401 , 176450

execute rdt.rdtAddMsg 176401, 10, '176401 UPDPKINFO Err',   'us_english', 840
execute rdt.rdtAddMsg 176402, 10, '176402 UPD REFNO Err',   'us_english', 840
execute rdt.rdtAddMsg 176403, 10, '176403 No MBOLKEY   ',   'us_english', 840
execute rdt.rdtAddMsg 176404, 10, '176404 BEnd MBOL Err',   'us_english', 840

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 176401 AND 176450


