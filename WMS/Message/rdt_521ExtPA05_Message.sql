--rdt_521ExtPA05
rdt.rdtDropMsg 150451 , 150500

execute rdt.rdtAddMsg 150451, 10, '50451^NotLoosePallet',      'us_english', 521
execute rdt.rdtAddMsg 150452, 10, '50452^StrategyNotSet',      'us_english', 521
execute rdt.rdtAddMsg 150453, 10, '50453^BadStrategyKey',      'us_english', 521
execute rdt.rdtAddMsg 150454, 10, '50454^No Suggested Loc',    'us_english', 521
execute rdt.rdtAddMsg 150455, 10, '50455^UpdRFPutaway Err',    'us_english', 521
execute rdt.rdtAddMsg 150456, 10, '50456^No Home Loc',         'us_english', 521
execute rdt.rdtAddMsg 150457, 10, '50457^No Suggested Loc',    'us_english', 521

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 150451 AND 150500
