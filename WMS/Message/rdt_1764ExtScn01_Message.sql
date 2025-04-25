--rdt_1764ExtScn01
--UWP-31321 
execute rdt.rdtdropmsg 234851 , 234900

execute rdt.rdtAddMsg 234851, 10, '234851 UpdPKTaskFail',   'us_english', 840

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 234851 AND 234900