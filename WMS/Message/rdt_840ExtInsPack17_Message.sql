--rdt_840ExtInsPack17
exec rdt.rdtDropMsg 184401 , 184450

execute rdt.rdtAddMsg 184401, 10, '184401 UpdLog Failed',   'us_english', 840
execute rdt.rdtAddMsg 184402, 10, '184402 InsLog Failed',   'us_english', 840
execute rdt.rdtAddMsg 184403, 10, '184403 InsPKHDR Err ',   'us_english', 840
execute rdt.rdtAddMsg 184404, 10, '184404 UPDPKDET Err ',   'us_english', 840
execute rdt.rdtAddMsg 184405, 10, '184405 GET LABEL Err',   'us_english', 840
execute rdt.rdtAddMsg 184406, 10, '184406 GET LABEL Err',   'us_english', 840
execute rdt.rdtAddMsg 184407, 10, '184407 GET LABEL Err',   'us_english', 840
execute rdt.rdtAddMsg 184408, 10, '184408 INS PACK Fail',   'us_english', 840
execute rdt.rdtAddMsg 184409, 10, '184409 INS PACK Fail',   'us_english', 840
execute rdt.rdtAddMsg 184410, 10, '184410 INS PACK Fail',   'us_english', 840
execute rdt.rdtAddMsg 184411, 10, '184411 INS RDSNo Err',   'us_english', 840
execute rdt.rdtAddMsg 184412, 10, '184412 SNO ady scan ',   'us_english', 840
execute rdt.rdtAddMsg 184413, 10, '184413 INS PDInfoErr',   'us_english', 840
execute rdt.rdtAddMsg 184414, 10, '184414 UPD PDInfoErr',   'us_english', 840


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 184401 AND 184450


