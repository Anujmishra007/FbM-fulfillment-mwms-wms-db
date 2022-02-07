-- rdtPalletLabelReprn
-- EXEC RDT.RDTDROPMSG 87201, 87250


execute rdt.rdtAddMsg '87201', 10, '87201^VALUE REQ',      'us_english'
execute rdt.rdtAddMsg '87202', 10, '87202^INV ASN',        'us_english'
execute rdt.rdtAddMsg '87203', 10, '87203^INV ID',         'us_english'
execute rdt.rdtAddMsg '87204', 10, '87204^LabelPrnterReq', 'us_english'

-- SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 87201 AND 87250
