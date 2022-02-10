-- rdt_TM_Assist_Putaway_Confirm
rdt.rdtDropMsg 143851 , 143900

execute rdt.rdtAddMsg 143851, 10, '43851^143851UPD Task Fail ',    'us_english', 1815


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 143851 AND 143900