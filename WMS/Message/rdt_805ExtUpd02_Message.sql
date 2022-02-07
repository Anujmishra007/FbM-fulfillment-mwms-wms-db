--rdt_805ExtUpd02
rdt.rdtDropMsg 166701 , 166750	

execute rdt.rdtAddMsg 166701, 10, 'RESIDUAL PUTAWAY',    'us_english', 805
execute rdt.rdtAddMsg 166702, 10, 'EMPTY BOX',           'us_english', 805

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 166701 AND 166750