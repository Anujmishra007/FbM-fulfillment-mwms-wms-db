--rdt_1819ExtPASP64
--FCR-12893
execute rdt.rdtDropMsg 268401, 268450

execute rdt.rdtAddMsg 268401, 10, '268401 NoPutawayZone',         'us_english', 1819, 0, '268401 Missing SKU Putaway Zone'

SELECT * FROM RDT.RDTMsg WHERE Message_ID BETWEEN 268401 AND 268450