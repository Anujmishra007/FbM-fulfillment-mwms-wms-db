--rdt_UCCPreRCVAudit_Close
execute rdt.rdtdropmsg 90251, 90300

execute rdt.rdtAddMsg 90251, 10, '90251 UPD UCC Fail  ', 'us_english', 845
execute rdt.rdtAddMsg 90252, 10, '90252 UPD UCC Fail  ', 'us_english', 845
execute rdt.rdtAddMsg 90253, 10, '90253 INS UCC Fail  ', 'us_english', 845
execute rdt.rdtAddMsg 90254, 10, '90254 UPD Log Fail  ', 'us_english', 845
execute rdt.rdtAddMsg 90255, 10, '90255 UPD UCC Fail  ', 'us_english', 845
execute rdt.rdtAddMsg 90256, 10, '90256 UPD UCC Fail  ', 'us_english', 845
