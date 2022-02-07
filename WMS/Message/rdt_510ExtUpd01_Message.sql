-- rdt_510ExtUpd01
execute rdt.rdtDropMsg 146551 , 146600

execute rdt.rdtAddMsg 146551, 10, '46551^UPD PKDtl Fail',   'us_english', 510
execute rdt.rdtAddMsg 146552, 10, '46552^UPD PKDtl Fail',   'us_english', 510
execute rdt.rdtAddMsg 146553, 10, '46553^UPD PKDtl Fail',   'us_english', 510
execute rdt.rdtAddMsg 146554, 10, '46554^GetKey Fail',      'us_english', 510
execute rdt.rdtAddMsg 146555, 10, '46555^INS PKDtl Fail',   'us_english', 510
execute rdt.rdtAddMsg 146556, 10, '46556^INS RefKeyFail',   'us_english', 510
execute rdt.rdtAddMsg 146557, 10, '46557^UPD PKDtl Fail',   'us_english', 510
execute rdt.rdtAddMsg 146558, 10, '46558^UPD PKDtl Fail',   'us_english', 510
execute rdt.rdtAddMsg 146559, 10, '46559^UPD RPL Fail',     'us_english', 510

SELECT * FROM RDT.RDTMsg AS r (NOLOCK) WHERE r.Message_ID BETWEEN 146551 AND 146600
