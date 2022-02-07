-- rdt_HnMExtendedUpd03 
execute rdt.rdtDropMsg 95401 , 95450

execute rdt.rdtAddMsg 95401, 10, '95401^No PKSlip',      'us_english', 840
execute rdt.rdtAddMsg 95402, 10, '95402^No OrderKey',    'us_english', 840
execute rdt.rdtAddMsg 95403, 10, '95403^Upd OdHdr Fail', 'us_english', 840
execute rdt.rdtAddMsg 95404, 10, '95404^Upd OdDtl Fail', 'us_english', 840
execute rdt.rdtAddMsg 95405, 10, '95405^Upd LpDtl Fail', 'us_english', 840
execute rdt.rdtAddMsg 95406, 10, '95406^nspGetRightErr', 'us_english', 840
execute rdt.rdtAddMsg 95407, 10, '95407^GenTLog3 Fail',  'us_english', 840
execute rdt.rdtAddMsg 95408, 10, '95408^Upd Pack Fail',  'us_english', 840
execute rdt.rdtAddMsg 95409, 10, '95409^Cfm Pack Fail',  'us_english', 840

-- WMS-15010
execute rdt.rdtAddMsg 95410, 10, '95410^Assign Lbl Err','us_english', 840
execute rdt.rdtAddMsg 95411, 10, '95411^GetRightFail',  'us_english', 840
execute rdt.rdtAddMsg 95412, 10, '95412^AutoMBOLPack',  'us_english', 840

select * from rdt.rdtmsg (nolock) where message_id between 95401 AND 95450