--rdt_1653ExtUpd08
execute rdt.rdtDropMsg 204301 , 204350

execute rdt.rdtAddMsg 204301, 10, '204301 DelShtPickErr',   'us_english', 1653
execute rdt.rdtAddMsg 204302, 10, '204302 ShipLabel Err',   'us_english', 1653
execute rdt.rdtAddMsg 204303, 10, '204303 DelEcommFail ',   'us_english', 1653
execute rdt.rdtAddMsg 204304, 10, '204304 Del PickDt Er',   'us_english', 1653
execute rdt.rdtAddMsg 204305, 10, '204305 Del PickDt Er',   'us_english', 1653
execute rdt.rdtAddMsg 204306, 10, '204306 Del PackDt Er',   'us_english', 1653
execute rdt.rdtAddMsg 204307, 10, '204307 Del PackIf Er',   'us_english', 1653
execute rdt.rdtAddMsg 204308, 10, '204308 Del PackHd Er',   'us_english', 1653
execute rdt.rdtAddMsg 204309, 10, '204309 Del TL2 Err  ',   'us_english', 1653
execute rdt.rdtAddMsg 204310, 10, '204310 Del WavDtl Er',   'us_english', 1653
execute rdt.rdtAddMsg 204311, 10, '204311 Upd UDF04 Err',   'us_english', 1653



SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 204301 AND 204350