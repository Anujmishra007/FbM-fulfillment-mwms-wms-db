-- rdtfnc_ScanToTruck_ByCBOL
-- 274851 - 274900
exec rdt.rdtDropMsg 274851, 274900

-- Screen 1 - CBOL validation
execute rdt.rdtAddMsg 274851, 10, '274851 Enter CBOL   ', 'us_english', 928
execute rdt.rdtAddMsg 274852, 10, '274852 CBOL Shipped ', 'us_english', 928
execute rdt.rdtAddMsg 274853, 10, '274853 NoMBOL4CBOL  ', 'us_english', 928
execute rdt.rdtAddMsg 274854, 10, '274854 MBOLsShipped ', 'us_english', 928

-- Screen 2 - LabelNo/DropID validation
execute rdt.rdtAddMsg 274855, 10, '274855 Need LabelNo ', 'us_english', 928
execute rdt.rdtAddMsg 274856, 10, '274856 LblAlrScaned ', 'us_english', 928
execute rdt.rdtAddMsg 274857, 10, '274857 BAD LBL/DrpID', 'us_english', 928
execute rdt.rdtAddMsg 274858, 10, '274858 NotPickCnfrm ', 'us_english', 928
execute rdt.rdtAddMsg 274859, 10, '274859 BAD LBL/DrpID', 'us_english', 928
execute rdt.rdtAddMsg 274860, 10, '274860 NotPackCnfrm ', 'us_english', 928
execute rdt.rdtAddMsg 274861, 10, '274861 BAD LBL/DrpID', 'us_english', 928
execute rdt.rdtAddMsg 274862, 10, '274862 IDNotInCBOL  ', 'us_english', 928
execute rdt.rdtAddMsg 274863, 10, '274863 INSTruckFail ', 'us_english', 928

-- Screen 3 - Pack info validation
execute rdt.rdtAddMsg 274864, 10, '274864 Bad Weight   ', 'us_english', 928
execute rdt.rdtAddMsg 274865, 10, '274865 Bad Cube     ', 'us_english', 928
execute rdt.rdtAddMsg 274866, 10, '274866 BadCartonType', 'us_english', 928
execute rdt.rdtAddMsg 274867, 10, '274867 UPDPckInfFal ', 'us_english', 928
execute rdt.rdtAddMsg 274868, 10, '274868 INSPckInfFal ', 'us_english', 928

-- Screen 4 - Close MBOLs validation
execute rdt.rdtAddMsg 274869, 10, '274869 Need Option  ', 'us_english', 928
execute rdt.rdtAddMsg 274870, 10, '274870 Inv Option   ', 'us_english', 928
execute rdt.rdtAddMsg 274871, 10, '274871 ClseMBOLErr  ', 'us_english', 928
execute rdt.rdtAddMsg 274872, 10, '274872 CnfrmStsNtMn ', 'us_english', 928
