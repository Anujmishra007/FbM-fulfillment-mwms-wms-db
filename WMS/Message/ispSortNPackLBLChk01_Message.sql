-- ispSortNPackLBLChk01
exec rdt.rdtDropMsg 108651, 108700

execute rdt.rdtAddMsg 108651, 10, '08651^Lbl Diff Store',   'us_english', 540
execute rdt.rdtAddMsg 108652, 10, '08652^Ctn Closed',       'us_english', 540

select * from rdt.rdtmsg (nolock) where message_id between 108651 and 108700