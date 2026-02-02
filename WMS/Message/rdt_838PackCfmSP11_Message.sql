-- rdt_838PackCfmSP11
execute rdt.rdtDropMsg 253051, 253100

execute rdt.rdtAddMsg 253051, 10, '253051 UpdPackHeaderFail',  'us_english', 838, 0, '253051 Update PackHeader Failed'
execute rdt.rdtAddMsg 253052, 10, '253052 InsPKInfFail',       'us_english', 838, 0, '253052 Insert PackInfo Failed'

SELECT * FROM rdt.rdtMsg WHERE Message_ID BETWEEN 253051 AND 253100