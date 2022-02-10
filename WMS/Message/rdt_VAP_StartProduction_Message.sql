--rdt_VAP_StartProduction
execute rdt.rdtdropmsg 100651 , 100700

--execute rdt.rdtAddMsg 100651, 10, '00651^ACTIVE FAIL',       'us_english', 1156--**
--execute rdt.rdtAddMsg 100652, 10, '00652^UPD WKSTN FAIL',    'us_english', 1156--**
--execute rdt.rdtAddMsg 100653, 10, '00653^INS WKLOG FAIL',    'us_english', 1156--**
execute rdt.rdtAddMsg 100654, 10, '00654^GETKEY FAIL',       'us_english', 1156
execute rdt.rdtAddMsg 100655, 10, '00655^ACTIVATE FAIL',     'us_english', 1156
execute rdt.rdtAddMsg 100656, 10, '00656^INS WKLOG FAIL',    'us_english', 1156
execute rdt.rdtAddMsg 100657, 10, '00657^END JOB FAIL',      'us_english', 1156
execute rdt.rdtAddMsg 100658, 10, '00658^INS WKLOG FAIL',    'us_english', 1156
execute rdt.rdtAddMsg 100659, 10, '00659^START JOB FAIL',    'us_english', 1156
execute rdt.rdtAddMsg 100660, 10, '00660^START JOB FAIL',    'us_english', 1156
execute rdt.rdtAddMsg 100661, 10, '00661^INS WKLOG FAIL',    'us_english', 1156
execute rdt.rdtAddMsg 100662, 10, '00662^PAUSE JOB FAIL',    'us_english', 1156
execute rdt.rdtAddMsg 100663, 10, '00663^START JOB FAIL',    'us_english', 1156
execute rdt.rdtAddMsg 100664, 10, '00664^START JOB FAIL',    'us_english', 1156
execute rdt.rdtAddMsg 100665, 10, '00665^INS WKLOG FAIL',    'us_english', 1156
execute rdt.rdtAddMsg 100666, 10, '00666^START JOB FAIL',    'us_english', 1156

--WMS-16844
execute rdt.rdtAddMsg 100667, 10, '00667^UPDWORKORDEREr',    'us_english', 1156

select * from rdt.rdtmsg (nolock) where message_id between 100651 and 100700