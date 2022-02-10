-- rdt_598RcvCfm02
execute rdt.rdtDropMsg 169551, 169600

execute rdt.rdtAddMsg 169551, 10, '169551 Offset error ', 'us_english', 598 
execute rdt.rdtAddMsg 169552, 10, '169552 UPD UCC Fail ', 'us_english', 598 

SELECT * FROM rdt.rdtMsg (NOLOCK) WHERE Message_ID BETWEEN  169551 and 169600
