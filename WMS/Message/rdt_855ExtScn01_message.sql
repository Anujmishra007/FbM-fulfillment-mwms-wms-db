--rdt_855ExtValid07
rdt.rdtDropMsg 217351, 217400

execute rdt.rdtAddMsg 217351, 10, '217351 InvalidOption',     'us_english', 855
execute rdt.rdtAddMsg 217352, 10, '217352 CtnIdReq',     'us_english', 855, 0, 'DropID or CaseID required'
execute rdt.rdtAddMsg 217353, 10, '217353 CaseIdInvalid',     'us_english', 855, 0, 'DropID or CaseID invalid'


SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 217351 AND 217400