--rdt_LottableProcess_BRF_GenL13
--FCR-12670 BRF Saudi MLP - Normal Receiving - Batch conversion
execute rdt.rdtDropMsg 268201, 268250

execute rdt.rdtAddMsg 268201, 10, '268201^ShelfLife Miss', 'us_english', 600
execute rdt.rdtAddMsg 268202, 10, '268202^Prod in Future', 'us_english', 600
execute rdt.rdtAddMsg 268203, 10, '268203^Expiry too old', 'us_english', 600

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE MESSAGE_ID BETWEEN 268201 AND 268250
