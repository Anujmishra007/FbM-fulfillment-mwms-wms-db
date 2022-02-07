--rdt_Replenish_V7_Confirm 
execute rdt.rdtDropMsg 141551 , 141600	

execute rdt.rdtAddMsg 141551, 10, '41551^Upd RPL Fail',     'us_english', 896
execute rdt.rdtAddMsg 141552, 10, '41552^Offset Error',     'us_english', 896
execute rdt.rdtAddMsg 141553, 10, '41553^Upd RPL Fail',     'us_english', 896

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 141551 AND 141600	

