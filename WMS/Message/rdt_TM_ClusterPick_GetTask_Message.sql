--rdt_TM_Cluster_Pick_GetTask
rdt.rdtDropMsg 148951 , 149000

execute rdt.rdtAddMsg 148951, 10, '48951^No Task',    'us_english', 640

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 148951 AND 149000