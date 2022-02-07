-- ispUpdatePackSerialNo
execute rdt.rdtDropMsg 110201, 110250

execute rdt.rdtAddMsg 110201, 10, '110201Bad FromDropID', 'us_english'
execute rdt.rdtAddMsg 110202, 10, '110202UPDPickDtlFail', 'us_english'
execute rdt.rdtAddMsg 110203, 10, '110203GetKey fail   ', 'us_english'
execute rdt.rdtAddMsg 110204, 10, '110204INSPickDtlFail', 'us_english'
execute rdt.rdtAddMsg 110205, 10, '110205UPDPickDtlFail', 'us_english'
execute rdt.rdtAddMsg 110206, 10, '110206UPDPackSNOFail', 'us_english'
execute rdt.rdtAddMsg 110207, 10, '110207Offset Fail   ', 'us_english'
