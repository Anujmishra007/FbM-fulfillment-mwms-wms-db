--rdt_727Inquiry08
rdt.rdtDropMsg 169851 , 169900	

execute rdt.rdtAddMsg 169851, 10, '169851 ID Req       ',   'us_english', 727

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 169851 AND 169900