-- rdt_840ExtUpd20
execute rdt.rdtDropMsg 187751 , 187800

execute rdt.rdtAddMsg 187751, 10, '187751 GetRightFail ',   'us_english', 840
execute rdt.rdtAddMsg 187752, 10, '187752 AutoMBOLPack ',   'us_english', 840
execute rdt.rdtAddMsg 187753, 10, '187753 PACKCFM FAIL ',   'us_english', 840
execute rdt.rdtAddMsg 187754, 10, '187754INV SHIPPERKEY',   'us_english', 840
execute rdt.rdtAddMsg 187755, 10, '187755UPD PACKINF ER',   'us_english', 840

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 187751 AND 187800