--rdt_638RcvCfm06
exec rdt.rdtdropmsg 162501, 162550

execute rdt.rdtAddMsg 162501, 10, '62501^INVALID TOLOC', 'us_english', 638

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 162501 AND 162550

