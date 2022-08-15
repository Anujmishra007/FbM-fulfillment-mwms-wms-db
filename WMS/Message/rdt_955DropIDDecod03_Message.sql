--rdt_955DropIDDecod02
exec rdt.rdtDropMsg 177151, 177200

execute rdt.rdtAddMsg 177151, 10, '177151^DropID Req   ',  'us_english', 955
EXECUTE rdt.rdtAddMsg 177152, 10, '177152^CaseSSCCErr  ',  'us_english', 955
execute rdt.rdtAddMsg 177153, 10, '177153^CaseSSCCErr  ',  'us_english', 955
execute rdt.rdtAddMsg 177154, 10, '177154^ScanCaseSSCC ',  'us_english', 955

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 177151 AND 177200