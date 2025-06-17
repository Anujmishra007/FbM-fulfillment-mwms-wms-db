--rdt_1764ExtScn01
--UWP-31321 
execute rdt.rdtdropmsg 234851 , 234900

execute rdt.rdtAddMsg 234851, 10, '234851 UpdPKTaskFail',   'us_english', 1764

--UWP-34785
execute rdt.rdtAddMsg 234852, 10, '234852 OptionNeeded',    'us_english', 1764
execute rdt.rdtAddMsg 234853, 10, '234853 InvalidOption',   'us_english', 1764

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 234851 AND 234900