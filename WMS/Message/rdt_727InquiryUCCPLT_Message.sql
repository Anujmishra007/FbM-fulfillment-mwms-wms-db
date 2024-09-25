--rdt_727InquiryUCCPLT
rdt.rdtDropMsg 224801 , 224850

execute rdt.rdtAddMsg 224801, 10, '224801Need ID OR LOC',         'us_english', 727
execute rdt.rdtAddMsg 224802, 10, '4224802No Records',            'us_english', 727

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 224801 AND 224850