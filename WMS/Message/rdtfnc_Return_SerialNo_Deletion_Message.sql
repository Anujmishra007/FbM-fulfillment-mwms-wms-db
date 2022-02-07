
-- Receipt Return with Serial No Delete (rdtfnc_Return_SerialNo_Deletion) Messages
-- **********************************************

--execute rdt.rdtDropMsg 65751, 65800
--execute rdt.rdtDropMsg 72416, 72440


execute rdt.rdtAddMsg 65751, 10, '65751 ASN/PO/PKSLIP req', 'us_english'
execute rdt.rdtAddMsg 65752, 10, '65752 Invalid ASN/PO', 'us_english'
execute rdt.rdtAddMsg 65753, 10, '65753 Invalid ASN/PO/PSNO', 'us_english'
execute rdt.rdtAddMsg 65754, 10, '65754 Invalid ASN/PSNO', 'us_english'
execute rdt.rdtAddMsg 65755, 10, '65755 Invalid PO/PSNO', 'us_english'
execute rdt.rdtAddMsg 65756, 10, '65756 PO not exists', 'us_english'
execute rdt.rdtAddMsg 65757, 10, '65757 ASN needed', 'us_english'
execute rdt.rdtAddMsg 65758, 10, '65758 PKSLIP not exists', 'us_english'
execute rdt.rdtAddMsg 65759, 10, '65759 ASN needed', 'us_english'
execute rdt.rdtAddMsg 65760, 10, '65760 ASN not exists', 'us_english'
execute rdt.rdtAddMsg 65761, 10, '65761 Diff facility', 'us_english'
execute rdt.rdtAddMsg 65762, 10, '65762 Diff storer', 'us_english'
execute rdt.rdtAddMsg 65763, 10, '65763 ASN closed', 'us_english'
execute rdt.rdtAddMsg 65764, 10, '65764 ASN closed', 'us_english'
execute rdt.rdtAddMsg 65765, 10, '65765 ASN cancelled', 'us_english'
execute rdt.rdtAddMsg 65766, 10, '65766 Not Return ASN', 'us_english'
execute rdt.rdtAddMsg 65767, 10, '65767 PO needed', 'us_english'
execute rdt.rdtAddMsg 65768, 10, '65768 SKU needed', 'us_english'
execute rdt.rdtAddMsg 65769, 10, '65769 Invalid SKU', 'us_english'
execute rdt.rdtAddMsg 65770, 10, '65770 MultiSKUBarcod', 'us_english'
execute rdt.rdtAddMsg 65771, 10, '65771 SKU not in ASN', 'us_english'
execute rdt.rdtAddMsg 65772, 10, '65772 Invalid QTY', 'us_english'
execute rdt.rdtAddMsg 65773, 10, '65773 Invalid QTY', 'us_english'
execute rdt.rdtAddMsg 65774, 10, '65774 Invalid QTY', 'us_english'
execute rdt.rdtAddMsg 65775, 10, '65775 QTY needed', 'us_english'
execute rdt.rdtAddMsg 65776, 10, '65776 Invalid Date', 'us_english'
execute rdt.rdtAddMsg 65777, 10, '65777 Lottable01 Req', 'us_english'
execute rdt.rdtAddMsg 65778, 10, '65778 Lottable02 Req', 'us_english'
execute rdt.rdtAddMsg 65779, 10, '65779 Lottable03 Req', 'us_english'
execute rdt.rdtAddMsg 65780, 10, '65780 Lottable04 Req', 'us_english'
execute rdt.rdtAddMsg 65781, 10, '65781 Serial# Required', 'us_english'
execute rdt.rdtAddMsg 65782, 10, '65782 SN# Not Exists', 'us_english'
execute rdt.rdtAddMsg 65783, 10, '65783 No Pick Face', 'us_english'
execute rdt.rdtAddMsg 65784, 10, '65784 No Return Loc', 'us_english'
execute rdt.rdtAddMsg 65785, 10, '65785 Return Reason', 'us_english'
execute rdt.rdtAddMsg 65786, 10, '65786 OverRcv Reason', 'us_english'
execute rdt.rdtAddMsg 65787, 10, '65787 Expired Reason', 'us_english'
execute rdt.rdtAddMsg 65788, 10, '65788 Bad Subreason', 'us_english'
execute rdt.rdtAddMsg 65789, 10, '65789 LOC needed', 'us_english'
execute rdt.rdtAddMsg 65790, 10, '65790 Invalid LOC', 'us_english'
execute rdt.rdtAddMsg 65791, 10, '65791 Diff facility', 'us_english'
execute rdt.rdtAddMsg 65792, 10, '65792 Delete SN# Err', 'us_english'
execute rdt.rdtAddMsg 65793, 10, '65793 Invalid Day', 'us_english'
execute rdt.rdtAddMsg 65794, 10, '65794 Invalid Day', 'us_english'
execute rdt.rdtAddMsg 65795, 10, '65795 Invalid Month', 'us_english'
execute rdt.rdtAddMsg 65796, 10, '65796 Invalid Month', 'us_english'
execute rdt.rdtAddMsg 65797, 10, '65797 Invalid Year', 'us_english'
execute rdt.rdtAddMsg 65798, 10, '65798 Invalid Year', 'us_english'

--SOS201989
execute rdt.rdtAddMsg 65799, 10, '65799 Inv ASN+PO+EXTR', 'us_english'
execute rdt.rdtAddMsg 65800, 10, '65800 Inv ASN+EXTR',    'us_english'
execute rdt.rdtAddMsg 72416, 10, '72416 Inv PO+EXTR',     'us_english'
execute rdt.rdtAddMsg 72417, 10, '72417 EXTR not exists', 'us_english'
execute rdt.rdtAddMsg 72418, 10, '72418 ASN needed',      'us_english'



