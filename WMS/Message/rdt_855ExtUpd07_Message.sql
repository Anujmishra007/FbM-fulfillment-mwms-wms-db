--rdt_855ExtUpd07
exec rdt.rdtDropMsg 171551, 171600

execute rdt.rdtAddMsg 171551, 10, '171551No Pickslip No', 'us_english', 855
execute rdt.rdtAddMsg 171552, 10, '171552Overpacked    ', 'us_english', 855
execute rdt.rdtAddMsg 171553, 10, '171553InsPackHdrFail', 'us_english', 855
execute rdt.rdtAddMsg 171554, 10, '171554InsPickInfFail', 'us_english', 855
execute rdt.rdtAddMsg 171555, 10, '171555InsPackDtlFail', 'us_english', 855
execute rdt.rdtAddMsg 171556, 10, '171556InsPackDtlFail', 'us_english', 855
execute rdt.rdtAddMsg 171557, 10, '171557UpdPackDtlFail', 'us_english', 855
execute rdt.rdtAddMsg 171558, 10, '171558InsPackDtlFail', 'us_english', 855
execute rdt.rdtAddMsg 171559, 10, '171559PackCfm Fail  ', 'us_english', 855
execute rdt.rdtAddMsg 171560, 10, '71560InsPkDtlInfoErr', 'us_english', 855
execute rdt.rdtAddMsg 171561, 10, '71561UpdPkDtlInfoErr', 'us_english', 855


SELECT * FROM rdt.rdtMsg (NOLOCK) WHERE Message_ID BETWEEN 171551 AND  171600

