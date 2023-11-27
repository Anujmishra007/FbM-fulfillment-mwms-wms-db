--rdt_1664ExtValidSP06
exec rdt.rdtDropMsg 208651 , 208700

execute rdt.rdtAddMsg 208651, 10, '208651 Mismatch MBOL', 'us_english', 1664
execute rdt.rdtAddMsg 208652, 10, '208652 Mismatch MBOL', 'us_english', 1664

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 208651 AND 208700

