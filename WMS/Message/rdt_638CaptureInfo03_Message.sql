--rdt_638CaptureInfo03
exec rdt.rdtdropmsg 165251, 165300

execute rdt.rdtAddMsg 165251, 10, '65251^Data Not Found', 'us_english', 638
execute rdt.rdtAddMsg 165252, 10, '65252^Need data     ', 'us_english', 638
execute rdt.rdtAddMsg 165253, 10, '65253^Invalid format', 'us_english', 638
execute rdt.rdtAddMsg 165254, 10, '65254^Invalid value ', 'us_english', 638

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 165251 AND 165300
