--rdt_SortationByTrackingID
rdt.rdtDropMsg 149401 , 149450	

execute rdt.rdtAddMsg 149401, 10, '49401^Ins Track Fail',       'us_english', 641
execute rdt.rdtAddMsg 149402, 10, '49402^Upd Track Fail',       'us_english', 641
execute rdt.rdtAddMsg 149403, 10, '49403^Del Track Fail',       'us_english', 641
execute rdt.rdtAddMsg 149404, 10, '49404^Del Track Fail',       'us_english', 641
execute rdt.rdtAddMsg 149405, 10, '49405^Del Track Fail',       'us_english', 641


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 149401 AND 149450	