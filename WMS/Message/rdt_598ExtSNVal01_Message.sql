-- rdt_598ExtSNVal01
execute rdt.rdtDropMsg 241651, 241700

execute rdt.rdtAddMsg 241651, 10, '241651InvSerialNo', 'us_english', 598 

SELECT * FROM rdt.rdtMsg (NOLOCK) WHERE Message_ID BETWEEN  241651 and 241700
