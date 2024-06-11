--rdt_1812CreateTask02
execute rdt.rdtdropmsg 215851, 215900

execute rdt.rdtAddMsg 215851, 10, '215851 GetKey Fail   ', 'us_english', 1812
execute rdt.rdtAddMsg 215852, 10, '215852 GetKey Fail   ', 'us_english', 1812
execute rdt.rdtAddMsg 215853, 10, '215853 INSTaskDTLFail', 'us_english', 1812
execute rdt.rdtAddMsg 215854, 10, '215854 INSTaskDTLFail', 'us_english', 1812
execute rdt.rdtAddMsg 215855, 10, '215855 INSTaskDTLFail', 'us_english', 1812

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 215851 AND 215900
