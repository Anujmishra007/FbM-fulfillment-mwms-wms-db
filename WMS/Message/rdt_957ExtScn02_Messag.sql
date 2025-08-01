--rdt_957ExtScn02
--FCR-454
execute rdt.rdtdropmsg 218901, 218950

execute rdt.rdtAddMsg 218901, 10, '218901 SSCC Needed',     'us_english', 957
execute rdt.rdtAddMsg 218902, 10, '218902 Invalid SSCC',    'us_english', 957
execute rdt.rdtAddMsg 218903, 10, '218903 UCCNeeded',       'us_english', 957
execute rdt.rdtAddMsg 218904, 10, '218904 Invalid UCC',     'us_english', 957
execute rdt.rdtAddMsg 218905, 10, '218905 Invalid UCC',     'us_english', 957
execute rdt.rdtAddMsg 218906, 10, '218906 Invalid UCC',     'us_english', 957
execute rdt.rdtAddMsg 218907, 10, '218907 InvalidOption',   'us_english', 957
execute rdt.rdtAddMsg 218908, 10, '218908 EmptyDropID',     'us_english', 957
execute rdt.rdtAddMsg 218909, 10, '218909 UpdDataFail',     'us_english', 957
execute rdt.rdtAddMsg 218910, 10, '218910 NoUcc',           'us_english', 957
execute rdt.rdtAddMsg 218911, 10, '218911 ToLocNeeded',     'us_english', 957
execute rdt.rdtAddMsg 218912, 10, '218912 MoveUCCFail',     'us_english', 957
execute rdt.rdtAddMsg 218913, 10, '218913 IncorrectSetup',  'us_english', 957
execute rdt.rdtAddMsg 218914, 10, '218914 IncorrectSetup',  'us_english', 957
execute rdt.rdtAddMsg 218915, 10, '218915 DropPalletFail',  'us_english', 957
execute rdt.rdtAddMsg 218916, 10, '218916 OptionNeeded',    'us_english', 957
execute rdt.rdtAddMsg 218917, 10, '218917 InvalidOption',   'us_english', 957
execute rdt.rdtAddMsg 218918, 10, '218918 UCCPicked',       'us_english', 957
execute rdt.rdtAddMsg 218919, 10, '218919 InvalidLoc',      'us_english', 957
execute rdt.rdtAddMsg 218920, 10, '218920 SwapUCCFail',     'us_english', 957
execute rdt.rdtAddMsg 218921, 10, '218921 CdlookupErr',     'us_english', 957
execute rdt.rdtAddMsg 218922, 10, '218922 NotAllowSwap',    'us_english', 957, 0, '218922 Not allow to swap UCC'

SELECT * FROM RDT.RDTMSG WITH(NOLOCK) WHERE Message_ID BETWEEN 218901 AND 218950
