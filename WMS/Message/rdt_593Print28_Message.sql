-- rdt_593Print28
rdt.rdtDropMsg 150751 , 150800	

execute rdt.rdtAddMsg 150751, 10, '50751^NEED VALUE',       'us_english', 593
execute rdt.rdtAddMsg 150752, 10, '50752^INVALID UCCNO',    'us_english', 593

-- WMS-15422
execute rdt.rdtAddMsg 150753, 10, '50753^GEN SSCC FAIL',    'us_english', 593
execute rdt.rdtAddMsg 150754, 10, '50754^UPD CASEID ERR',   'us_english', 593
execute rdt.rdtAddMsg 150755, 10, '50755^UPD LABEL# ERR',   'us_english', 593
execute rdt.rdtAddMsg 150756, 10, '50756^UPD CASEID ERR',   'us_english', 593

--WMS-18429
execute rdt.rdtAddMsg 150757, 10, '50757^No LoadPlan   ',   'us_english', 593

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 150751 AND 150800
