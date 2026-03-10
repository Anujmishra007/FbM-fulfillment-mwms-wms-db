--rdt_605RcvCfm05
--259901 - 259950

rdt.rdtDropMsg 259901, 259950

execute rdt.rdtAddMsg 259901, 10, '259901^InvalidOpt',          'us_english', 605, 0, '259901 Invalid option'
execute rdt.rdtAddMsg 259902, 10, '259902^IDReceived',          'us_english', 605, 0, '259902 ToID was received'
execute rdt.rdtAddMsg 259903, 10, '259903^ASNConfirmed',        'us_english', 605, 0, '259903 ASN line was confirmed'
execute rdt.rdtAddMsg 259904, 10, '259904^NeedToLoc',           'us_english', 605, 0, '259904 Need ToLoc'
execute rdt.rdtAddMsg 259905, 10, '259905^InsPltFail',          'us_english', 605, 0, '259905 Insert Pallet Fail'
execute rdt.rdtAddMsg 259906, 10, '259906^CloseASNFail',        'us_english', 605, 0, '259906 Close ASN Fail'
execute rdt.rdtAddMsg 259907, 10, '259907^GenIMLFail',          'us_english', 605, 0, '259907 Gen TransmitLog2 Fail'
execute rdt.rdtAddMsg 259908, 10, '259908^GenIMLFail',          'us_english', 605, 0, '259908 Gen TransmitLog3 Fail'
execute rdt.rdtAddMsg 259909, 10, '259909^GenIMLFail',          'us_english', 605, 0, '259909 Gen TransmitLog by ASN Fail'
execute rdt.rdtAddMsg 259910, 10, '259910^GenTaskKeyFail',      'us_english', 605, 0, '259910 Gen TaskKey Fail'
execute rdt.rdtAddMsg 259911, 10, '259911^InsTaskFail',         'us_english', 605, 0, '259911 Insert Task Fail'
execute rdt.rdtAddMsg 259912, 10, '259912^OpenTaskExists',      'us_english', 605, 0, '259912 ID has a open ASTPA task'
execute rdt.rdtAddMsg 259913, 10, '259913^FailToLockSuggLoc',   'us_english', 605, 0, '259913 Failed to lock suggested loc'

select * from rdt.rdtmsg (NOLOCK) where message_id between 259901 and 259950

