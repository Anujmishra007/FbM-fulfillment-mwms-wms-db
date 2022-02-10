-- rdtfnc_UCCPreRCVAudit
exec rdt.rdtDropMsg 88751, 88800

execute rdt.rdtAddMsg 88751, 10, '88751^Need UCC      ', 'us_english', 845
execute rdt.rdtAddMsg 88752, 10, '88752^Key either one', 'us_english', 845
execute rdt.rdtAddMsg 88753, 10, '88753^Invalid UCC   ', 'us_english', 845
execute rdt.rdtAddMsg 88754, 10, '88754^UCC received  ', 'us_english', 845
execute rdt.rdtAddMsg 88755, 10, '88755^UCC NO ASN    ', 'us_english', 845
execute rdt.rdtAddMsg 88756, 10, '88756^UCC not exists', 'us_english', 845
execute rdt.rdtAddMsg 88757, 10, '88757^SKU required  ', 'us_english', 845
execute rdt.rdtAddMsg 88758, 10, '88758^Invalid SKU   ', 'us_english', 845
execute rdt.rdtAddMsg 88759, 10, '88759^SKU Not in ASN', 'us_english', 845
execute rdt.rdtAddMsg 88760, 10, '88760^Need UCC      ', 'us_english', 845
execute rdt.rdtAddMsg 88761, 10, '88761^Invalid format', 'us_english', 845
execute rdt.rdtAddMsg 88762, 10, '88762^UCC diff PO   ', 'us_english', 845
execute rdt.rdtAddMsg 88763, 10, '88763^Option require', 'us_english', 845
execute rdt.rdtAddMsg 88764, 10, '88764^Invalid Option', 'us_english', 845
execute rdt.rdtAddMsg 88765, 10, '88765^Need new UCC  ', 'us_english', 845
execute rdt.rdtAddMsg 88766, 10, '88766^Option require', 'us_english', 845
execute rdt.rdtAddMsg 88767, 10, '88767^Invalid Option', 'us_english', 845
execute rdt.rdtAddMsg 88768, 10, '88768^UCC no RDM/CIQ', 'us_english', 845
execute rdt.rdtAddMsg 88769, 10, '88769^UCC checked   ', 'us_english', 845
execute rdt.rdtAddMsg 88770, 10, '88770^Mix CIQ/NotCIQ', 'us_english', 845
execute rdt.rdtAddMsg 88771, 10, '88771^DiffNotConfirm', 'us_english', 845

--wms-17896
execute rdt.rdtAddMsg 88772, 10, '88772^Invalid SKU   ', 'us_english', 845

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 88751 and 88800
