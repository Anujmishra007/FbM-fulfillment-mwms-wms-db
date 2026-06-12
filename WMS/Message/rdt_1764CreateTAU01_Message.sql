--  268851 - 268900
execute rdt.rdtdropmsg 268851, 268900

execute rdt.rdtAddMsg 268851, 10, '268851^nspg_getkey   ', 'us_english', 1764
execute rdt.rdtAddMsg 268852, 10, '268852^InsTaskDetFail', 'us_english', 1764
execute rdt.rdtAddMsg 268853, 10, '268853^InsTaskDetFail', 'us_english', 1764
execute rdt.rdtAddMsg 268854, 10, '268854^UpdPickDtlFail', 'us_english', 1764
execute rdt.rdtAddMsg 268855, 10, '268855^UpdPickDtlFail', 'us_english', 1764
execute rdt.rdtAddMsg 268856, 10, '268856^UpdPickDtlFail', 'us_english', 1764

select * from rdt.rdtmsg WITH (NOLOCK) where message_id between 268851 and 268900 