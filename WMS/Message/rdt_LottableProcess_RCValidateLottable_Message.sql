--rdt_LottableProcess_RCValidateLottable
execute rdt.rdtdropmsg 164751 , 164800

execute rdt.rdtAddMsg 164751, 10, '64751^Need Lot06',       'us_english',600
execute rdt.rdtAddMsg 164752, 10, '64752^Data Not Found',   'us_english',600

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 164751 AND 164800