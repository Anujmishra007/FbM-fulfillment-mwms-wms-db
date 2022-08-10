--rdt_840ExtUpd13
rdt.rdtDropMsg 167551 , 167600	

execute rdt.rdtAddMsg 167551, 10, '167551 nCounter Err',    'us_english', 840
execute rdt.rdtAddMsg 167552, 10, '167552 nspg_getkey',     'us_english', 840
execute rdt.rdtAddMsg 167553, 10, '167553 nCounter Err',    'us_english', 840
execute rdt.rdtAddMsg 167554, 10, '167554 nspg_getkey',     'us_english', 840
execute rdt.rdtAddMsg 167555, 10, '167555 nCounter Err',    'us_english', 840
execute rdt.rdtAddMsg 167556, 10, '167556 nspg_getkey',     'us_english', 840
execute rdt.rdtAddMsg 167557, 10, '167557 nCounter Err',    'us_english', 840
execute rdt.rdtAddMsg 167558, 10, '167558 nspg_getkey',     'us_english', 840
execute rdt.rdtAddMsg 167559, 10, '167559UPDPackInfoErr',   'us_english', 840
execute rdt.rdtAddMsg 167560, 10, '167560UPDPackInfoErr',   'us_english', 840
execute rdt.rdtAddMsg 167561, 10, '167561UPD CtnWgt Err',   'us_english', 840
execute rdt.rdtAddMsg 167562, 10, '167562GetRightFail',     'us_english', 840
execute rdt.rdtAddMsg 167563, 10, '167563AutoMBOLPack',     'us_english', 840
execute rdt.rdtAddMsg 167564, 10, '167564ConfPackFail',     'us_english', 840
execute rdt.rdtAddMsg 167565, 10, '167565 PS Scan Out',     'us_english', 840
execute rdt.rdtAddMsg 167566, 10, '167566 PS Pack Cfm',     'us_english', 840

-- WMS17730
execute rdt.rdtAddMsg 167567, 10, '167567RequestTrackNo',   'us_english', 840

--WMS20379
execute rdt.rdtAddMsg 167568, 10, '167568UPDPackInfoErr',   'us_english', 840
execute rdt.rdtAddMsg 167569, 10, '167569UPD Orders Err',   'us_english', 840

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 167551 AND 167600