-- rdtCtnManifestReprn
-- EXEC RDT.RDTDROPMSG 84501, 84550

execute rdt.rdtAddMsg '84501', 10, '84501^VALUE REQ',      'us_english'
execute rdt.rdtAddMsg '84502', 10, '84502^INV ORDERKEY',   'us_english'
execute rdt.rdtAddMsg '84503', 10, '84503^PACK NOT CONF',  'us_english'
execute rdt.rdtAddMsg '84504', 10, '84504^INV DROP ID',    'us_english'
execute rdt.rdtAddMsg '84505', 10, '84505^LabelPrnterReq', 'us_english'
execute rdt.rdtAddMsg '84506', 10, '84506^DWNOTSetup',     'us_english'
execute rdt.rdtAddMsg '84507', 10, '84507^TgetDB Not Set', 'us_english'
execute rdt.rdtAddMsg '84508', 10, '84508^PrintSPXSETUP',  'us_english'

-- SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 84501 AND 84550
