--rdt_Replenish_V7_GetNextTask
execute rdt.rdtDropMsg 141501 , 141550	

execute rdt.rdtAddMsg 141501, 10, '41501^No more task',  'us_english', 896

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 141501 AND 141550	

