--rdt_VerifySKU_CaseCNT
execute rdt.rdtDropMsg 59701, 59750

execute rdt.rdtAddMsg 59701, 10, '59701 Need CaseCount',   'us_english'
execute rdt.rdtAddMsg 59702, 10, '59702 Bad CaseCnt   ',   'us_english'
execute rdt.rdtAddMsg 59703, 10, '59703 NoChg,HvInvBal',   'us_english'
execute rdt.rdtAddMsg 59704, 10, '59704 UPD PkKey Fail',   'us_english'
