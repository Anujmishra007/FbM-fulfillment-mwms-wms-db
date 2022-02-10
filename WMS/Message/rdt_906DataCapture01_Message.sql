--rdt_906DataCapture01
execute rdt.rdtDropMsg 136851, 136900

execute rdt.rdtAddMsg 136851, 10, '36851^SKU NotIn Ord',    'us_english'
execute rdt.rdtAddMsg 136852, 10, '36852^Batch NotInOrd',   'us_english'
execute rdt.rdtAddMsg 136853, 10, '36853^CaseID scanned',   'us_english'
execute rdt.rdtAddMsg 136854, 10, '36854^UPD PKDtl Fail',   'us_english'
execute rdt.rdtAddMsg 136855, 10, '36855^UPD PKDtl Fail',   'us_english'
execute rdt.rdtAddMsg 136856, 10, '36856^GetKey Fail',      'us_english'
execute rdt.rdtAddMsg 136857, 10, '36857^INS PKDtl Fail',   'us_english'
execute rdt.rdtAddMsg 136858, 10, '36858^UPD PKDtl Fail',   'us_english'
execute rdt.rdtAddMsg 136859, 10, '36859^NoPKDtl Offset',   'us_english'
execute rdt.rdtAddMsg 136860, 10, '36860^NotFullyOffset',   'us_english'
execute rdt.rdtAddMsg 136861, 10, '36861^UPD UCC Fail',     'us_english'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 136851 AND 136900
