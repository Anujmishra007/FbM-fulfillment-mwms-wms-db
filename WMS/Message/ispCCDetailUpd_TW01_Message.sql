--ispCCDetailUpd_TW01
execute rdt.rdtdropmsg 101851 , 101900

execute rdt.rdtAddMsg 101851, 10, '01851^UpdCCDtlFail',     'us_english', 732
execute rdt.rdtAddMsg 101852, 10, '01852^UpdCCDtlFail',     'us_english', 732
execute rdt.rdtAddMsg 101853, 10, '01853^UpdCCDtlFail',     'us_english', 732
execute rdt.rdtAddMsg 101854, 10, '01854^UpdCCDtlFail',     'us_english', 732
execute rdt.rdtAddMsg 101855, 10, '01855^GetKeyFail',       'us_english', 732
execute rdt.rdtAddMsg 101856, 10, '01856^GetSheetNoFail',   'us_english', 732
execute rdt.rdtAddMsg 101857, 10, '01857^InsertCCFail',     'us_english', 732
execute rdt.rdtAddMsg 101858, 10, '01858^InsertCCFail',     'us_english', 732
execute rdt.rdtAddMsg 101859, 10, '01859^InsertCCFail',     'us_english', 732
execute rdt.rdtAddMsg 101860, 10, '01860^UpdCCDtlFail',     'us_english', 732
execute rdt.rdtAddMsg 101861, 10, '01861^UpdCounterFail',   'us_english', 732
execute rdt.rdtAddMsg 101862, 10, '01862^UpdCCDtlFail',     'us_english', 732
execute rdt.rdtAddMsg 101863, 10, '01863^UpdCCDtlFail',     'us_english', 732
execute rdt.rdtAddMsg 101864, 10, '01864^UpdCCDtlFail',     'us_english', 732
execute rdt.rdtAddMsg 101865, 10, '01865^UpdCCDtlFail',     'us_english', 732
execute rdt.rdtAddMsg 101866, 10, '01866^DelCCDtlFail',     'us_english', 732
execute rdt.rdtAddMsg 101867, 10, '01867^ResetCCDtlFail',   'us_english', 732

select * from rdt.rdtmsg (nolock) where message_id between 101851 AND 101900
