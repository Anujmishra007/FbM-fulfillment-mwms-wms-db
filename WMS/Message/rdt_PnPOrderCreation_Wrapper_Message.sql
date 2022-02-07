--rdt_PnPOrderCreation_Wrapper
--execute rdt.rdtdropmsg 89901, 89950
execute rdt.rdtAddMsg 89901, 10, '89901^STOREDPROC Req',    'us_english'
execute rdt.rdtAddMsg 89902, 10, '89902^STORERKEY Req',     'us_english'