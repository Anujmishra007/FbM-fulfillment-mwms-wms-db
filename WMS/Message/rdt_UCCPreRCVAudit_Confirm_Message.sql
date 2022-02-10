--rdt_UCCPreRCVAudit_Confirm
execute rdt.rdtdropmsg 88801, 88850

execute rdt.rdtAddMsg 88801, 10, '88801 INS Log Fail  ', 'us_english', 845
execute rdt.rdtAddMsg 88802, 10, '88802 UPD Log Fail  ', 'us_english', 845
