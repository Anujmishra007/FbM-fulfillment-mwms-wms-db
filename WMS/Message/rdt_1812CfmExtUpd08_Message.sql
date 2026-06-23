-- rdt_1812CfmExtUpd08
--270851 - 270900

execute rdt.rdtDropMsg 270851, 270900

execute rdt.rdtAddMsg 270851, 10, '270851^UpdUCCFail',    'us_english', 1812, 0, '270851: Update UCC status fail'

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 270851 AND 270900
