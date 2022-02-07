-- rdt_838ExtUpd04
execute rdt.rdtDropMsg 130901, 130950

execute rdt.rdtAddMsg 130901, 10, '30001^Upd Trk# Err  ', 'us_english', 838
execute rdt.rdtAddMsg 130902, 10, '30902^Upd CaseID Err', 'us_english', 838

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 130901 AND 130950