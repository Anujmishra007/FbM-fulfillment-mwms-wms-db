--rdt_957ExtScn04
--FCR-7737
execute rdt.rdtdropmsg 249201, 249250

execute rdt.rdtAddMsg 249201, 10, '249201 SSCC Needed',     'us_english', 957
execute rdt.rdtAddMsg 249202, 10, '249202 Invalid SSCC',    'us_english', 957
execute rdt.rdtAddMsg 249203, 10, '249203 UCCNeeded',       'us_english', 957
execute rdt.rdtAddMsg 249204, 10, '249204 Invalid UCC',     'us_english', 957
execute rdt.rdtAddMsg 249205, 10, '249205 Invalid UCC',     'us_english', 957
execute rdt.rdtAddMsg 249206, 10, '249206 Invalid UCC',     'us_english', 957
execute rdt.rdtAddMsg 249207, 10, '249207 InvalidOption',   'us_english', 957
execute rdt.rdtAddMsg 249208, 10, '249208 EmptyDropID',     'us_english', 957
execute rdt.rdtAddMsg 249209, 10, '249209 UpdDataFail',     'us_english', 957
execute rdt.rdtAddMsg 249210, 10, '249210 NoUcc',           'us_english', 957
execute rdt.rdtAddMsg 249211, 10, '249211 ToLocNeeded',     'us_english', 957
execute rdt.rdtAddMsg 249212, 10, '249212 MoveUCCFail',     'us_english', 957
execute rdt.rdtAddMsg 249213, 10, '249213 IncorrectSetup',  'us_english', 957
execute rdt.rdtAddMsg 249214, 10, '249214 IncorrectSetup',  'us_english', 957
execute rdt.rdtAddMsg 249215, 10, '249215 DropPalletFail',  'us_english', 957
execute rdt.rdtAddMsg 249216, 10, '249216 OptionNeeded',    'us_english', 957
execute rdt.rdtAddMsg 249217, 10, '249217 InvalidOption',   'us_english', 957
execute rdt.rdtAddMsg 249218, 10, '249218 UCCPicked',       'us_english', 957
execute rdt.rdtAddMsg 249219, 10, '249219 InvalidLoc',      'us_english', 957
execute rdt.rdtAddMsg 249220, 10, '249220 SwapUCCFail',     'us_english', 957
execute rdt.rdtAddMsg 249221, 10, '249221 CdlookupErr',     'us_english', 957
execute rdt.rdtAddMsg 249222, 10, '249222 UCCNotFound',    'us_english', 957
execute rdt.rdtAddMsg 249223, 10, '249223 UCCUOMNotValid',    'us_english', 957
execute rdt.rdtAddMsg 249224, 10, '249224 UCCNotValid',    'us_english', 957
execute rdt.rdtAddMsg 249225, 10, '249225 NeedDropID',    'us_english', 957
execute rdt.rdtAddMsg 249226, 10, '249226 UCCLOCNotValid',    'us_english', 957
execute rdt.rdtAddMsg 249227, 10, '249227 UCCIDNotValid',    'us_english', 957
execute rdt.rdtAddMsg 249228, 10, '249228 ToLocNeeded',     'us_english', 957   -- FCR-10631



SELECT * FROM RDT.RDTMSG WITH(NOLOCK) WHERE Message_ID BETWEEN 249201 AND 249250
