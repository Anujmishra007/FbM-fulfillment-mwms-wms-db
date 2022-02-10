-- rdt_804UnassignSP01
execute rdt.rdtDropMsg 132001 , 132050

execute rdt.rdtAddMsg 132001, 10, '32001^DEL LOG Fail', 'us_english', 804
execute rdt.rdtAddMsg 132002, 10, '32002^DEL PTL Fail', 'us_english', 804

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 132001 AND 132050
