--rdtfnc_PutawayByID
execute rdt.rdtdropmsg 52751, 52800

execute rdt.rdtAddMsg 52751, 10, '52751^From ID needed', 'us_english', 1819,0,'52751 From ID needed'
execute rdt.rdtAddMsg 52752, 10, '52752^Invalid ID    ', 'us_english', 1819,0,'52752 Invalid ID    '
execute rdt.rdtAddMsg 52753, 10, '52753^Need TO LOC   ', 'us_english', 1819,0,'52753 Need TO LOC   '
execute rdt.rdtAddMsg 52754, 10, '52754^Invalid LOC   ', 'us_english', 1819,0,'52754 Invalid LOC   '
execute rdt.rdtAddMsg 52755, 10, '52755^NotInStorerGrp', 'us_english', 1819,0,'52755 Not In Storer Group'
execute rdt.rdtAddMsg 52756, 10, '52756^NoSuitableLOC ', 'us_english', 1819,0,'52756 No Suitable LOC '
execute rdt.rdtAddMsg 52757, 10, '52757^LOC Not Match ', 'us_english', 1819,0,'52757 LOC Not Match '
execute rdt.rdtAddMsg 52758, 10, '52758^ID Allocated  ', 'us_english', 1819,0,'52758 ID Allocated  '
execute rdt.rdtAddMsg 52759, 10, '52759^ID Picked     ', 'us_english', 1819,0,'52759 ID Picked     '

--WNS7793
execute rdt.rdtAddMsg 52760, 10, '52760^Param NotSetup', 'us_english', 1819,0,'52760 Param NotSetup'

--FCR-8113
execute rdt.rdtAddMsg 52761, 10, '52761^InvalidFormat ', 'us_english', 1819,0,'52761 Invalid FromID Format'
execute rdt.rdtAddMsg 52762, 10, '52762^Option req    ', 'us_english', 1819,0,'52762 Option required'
execute rdt.rdtAddMsg 52763, 10, '52763^Invalid Option', 'us_english', 1819,0,'52763 Invalid Option'
execute rdt.rdtAddMsg 52764, 10, '52764^NeedReasonCode', 'us_english', 1819,0,'52764 Need reason code'
execute rdt.rdtAddMsg 52765, 10, '52765^Bad ReasonCode', 'us_english', 1819,0,'52765 Bad reason code'
execute rdt.rdtAddMsg 52766, 10, '52766^NoSuggLOC No99', 'us_english', 1819,0,'52766 Suggest alternate LOC only works when there is a suggested LOC'
