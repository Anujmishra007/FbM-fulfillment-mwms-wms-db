--rdt_607RcptCfm03
execute rdt.rdtdropmsg 136201 , 136250

execute rdt.rdtAddMsg 136201, 10, '36201^Upd Extern Fail', 'us_english', 607

select * from rdt.rdtmsg (nolock) where message_id between 136201 AND 136250
