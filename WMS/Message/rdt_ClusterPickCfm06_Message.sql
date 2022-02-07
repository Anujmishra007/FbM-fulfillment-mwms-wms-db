-- rdt_ClusterPickCfm06 
execute rdt.rdtDropMsg 111901 , 111950

execute rdt.rdtAddMsg 111901, 10, '11901^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 111902, 10, '11902^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 111903, 10, '11903^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 111904, 10, '11904^GetDetKeyFail',  'us_english'
execute rdt.rdtAddMsg 111905, 10, '11905^Ins PDtl Fail',  'us_english'
execute rdt.rdtAddMsg 111906, 10, '11906^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 111907, 10, '11907^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 111908, 10, '11908^SKU OverPacked', 'us_english'
execute rdt.rdtAddMsg 111909, 10, '11909^InsPHdrFail',    'us_english'
execute rdt.rdtAddMsg 111910, 10, '11910^GenLabelFail',   'us_english'
execute rdt.rdtAddMsg 111911, 10, '11911^InsPackDtlFail', 'us_english'
execute rdt.rdtAddMsg 111912, 10, '11912^InsPackDtlFail', 'us_english'
execute rdt.rdtAddMsg 111913, 10, '11913^UpdPackDtlFail', 'us_english'
execute rdt.rdtAddMsg 111914, 10, '11914^UPDPKLockFail',  'us_english'
execute rdt.rdtAddMsg 111915, 10, '11915^Scan In Fail',   'us_english'
execute rdt.rdtAddMsg 111916, 10, '11916^Scan In Fail',   'us_english'

--WMS-14577
execute rdt.rdtAddMsg 111917, 10, '11917^UPDPKLockFail',  'us_english'
execute rdt.rdtAddMsg 111918, 10, '11918^>SKU MaxCount',  'us_english'

select * from rdt.rdtmsg (nolock) where message_id between 111901 and 111950
