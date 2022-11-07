--rdtfnc_PalletInquiry
exec rdt.rdtDropMsg 191701 , 191750

execute rdt.rdtAddMsg 191701, 10, '191701 Need Value   ',   'us_english', 1667
execute rdt.rdtAddMsg 191702, 10, '191702 Ether 1 Value',   'us_english', 1667
execute rdt.rdtAddMsg 191703, 10, '191703 Inv PalletKey',   'us_english', 1667
execute rdt.rdtAddMsg 191704, 10, '191704 MBOL Shipped ',   'us_english', 1667
execute rdt.rdtAddMsg 191705, 10, '191705 OrdersIsInUse',   'us_english', 1667
execute rdt.rdtAddMsg 191706, 10, 'Locked By           ',   'us_english', 1667
execute rdt.rdtAddMsg 191707, 10, '191707 Order Shipped',   'us_english', 1667
execute rdt.rdtAddMsg 191708, 10, '191708 No Ord Found ',   'us_english', 1667
execute rdt.rdtAddMsg 191709, 10, '191709 MBOL Shipped ',   'us_english', 1667
execute rdt.rdtAddMsg 191710, 10, 'This User Not Allow ',   'us_english', 1667
execute rdt.rdtAddMsg 191711, 10, 'To Remove All Carton',   'us_english', 1667
execute rdt.rdtAddMsg 191712, 10, 'From Pallet         ',   'us_english', 1667
execute rdt.rdtAddMsg 191713, 10, '191713 Inv Carton Id',   'us_english', 1667
execute rdt.rdtAddMsg 191714, 10, '191714Ctn is Shipped',   'us_english', 1667
execute rdt.rdtAddMsg 191715, 10, '191715 Need Option  ',   'us_english', 1667
execute rdt.rdtAddMsg 191716, 10, '191716Invalid Option',   'us_english', 1667
execute rdt.rdtAddMsg 191717, 10, '191717 Invalid Value',   'us_english', 1667
execute rdt.rdtAddMsg 191718, 10, '191718Ctn Not In Ord',   'us_english', 1667
execute rdt.rdtAddMsg 191719, 10, '191719 Need Option  ',   'us_english', 1667
execute rdt.rdtAddMsg 191720, 10, '191720Invalid Option',   'us_english', 1667

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 191701 AND 191750

