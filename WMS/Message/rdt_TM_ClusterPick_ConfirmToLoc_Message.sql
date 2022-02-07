--rdt_TM_ClusterPick_ConfirmToLoc
rdt.rdtDropMsg 156801 , 156850

execute rdt.rdtAddMsg 156801, 10, '56801^Confirm Fail',   'us_english', 640

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 156801 AND 156850