-- rdt_Pack_LVSUSA_PackConfirm
execute rdt.rdtDropMsg 226901, 226950
execute rdt.rdtAddMsg 226901, 10, '226901NoPSNO', 'us_english', 993, 0, '226901 No PSNO Found'
execute rdt.rdtAddMsg 226902, 10, '226902NoOrder', 'us_english', 993, 0, '226902 No Order Found'
execute rdt.rdtAddMsg 226903, 10, '226903PackCfmFail', 'us_english', 993, 0, '226903 Pack Confirm Fail'



select * from rdt.rdtmsg (nolock) where message_id between 226901 AND 226950




