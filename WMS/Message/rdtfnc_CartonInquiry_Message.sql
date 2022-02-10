--rdtfnc_CartonInquiry
--execute rdt.rdtdropmsg 86201, 86250

execute rdt.rdtAddMsg 86201, 10, '86201^NEED CARTONID',   'us_english'
execute rdt.rdtAddMsg 86202, 10, '86202^INV CARTONID',    'us_english'
execute rdt.rdtAddMsg 86203, 10, '86203^INV CARTONID',    'us_english'


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 86201 AND 86250