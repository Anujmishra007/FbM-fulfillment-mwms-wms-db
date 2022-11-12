--isp_533LabelNoChk02
exec rdt.rdtDropMsg 189901 , 189950

execute rdt.rdtAddMsg 189901, 10, '189901ToIDDiffOrders',    'us_english', 533

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 189901 AND 189950
