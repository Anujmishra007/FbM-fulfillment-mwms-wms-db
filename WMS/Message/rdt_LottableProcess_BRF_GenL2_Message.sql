--rdt_LottableProcess_BRF_GenL2
--FCR-12670 BRF Saudi MLP - Normal Receiving - Batch conversion
execute rdt.rdtDropMsg 268251, 268300

execute rdt.rdtAddMsg 268251, 10, '268251^ShelfLife Miss', 'us_english', 600
execute rdt.rdtAddMsg 268252, 10, '268252^Prod in Future', 'us_english', 600
execute rdt.rdtAddMsg 268253, 10, '268253^Expiry too old', 'us_english', 600

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE MESSAGE_ID BETWEEN 268251 AND 268300
