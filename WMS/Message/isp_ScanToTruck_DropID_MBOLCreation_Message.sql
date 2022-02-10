
-- isp_ScanToTruck_DropID_MBOLCreation 77801 - 77850

exec rdt.rdtDropMsg 77801 , 77850
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 1716

execute rdt.rdtAddMsg 77801 ,10, '77801^INSERT INTO ORDERS Table Failed', 'us_english',@nFunc
execute rdt.rdtAddMsg 77802 ,10, '77802^INSERT INTO OrderInfo Table Failed', 'us_english',@nFunc
execute rdt.rdtAddMsg 77803 ,10, '77803^INSERT INTO MBOLDETAIL Table Failed', 'us_english',@nFunc
execute rdt.rdtAddMsg 77804 ,10, '77804^Insert Into LOADPLAN Failed. ', 'us_english',@nFunc
execute rdt.rdtAddMsg 77805 ,10, '77805^Update Orders Failed.', 'us_english',@nFunc
execute rdt.rdtAddMsg 77806 ,10, '77806^Update Orders Failed.', 'us_english',@nFunc
execute rdt.rdtAddMsg 77807 ,10, '77807^Update MBOLDetail Failed.', 'us_english',@nFunc
execute rdt.rdtAddMsg 77808 ,10, '77808^Insert LOADPLANDETAIL Failed', 'us_english',@nFunc
execute rdt.rdtAddMsg 77809 ,10, '77809^INSERT INTO ORDERDETAIL Table Failed', 'us_english',@nFunc
execute rdt.rdtAddMsg 77810 ,10, '77810^Update RefKeyLookUp Table Failed', 'us_english',@nFunc
execute rdt.rdtAddMsg 77811 ,10, '77811^Update PICKDETAIL Table Failed', 'us_english',@nFunc
execute rdt.rdtAddMsg 77812 ,10, '77812^Update ORDERDETAIL Table Failed', 'us_english',@nFunc
execute rdt.rdtAddMsg 77813 ,10, '77813^Update ORDERS Table Failed', 'us_english',@nFunc
execute rdt.rdtAddMsg 77814 ,10, '77814^Update ORDERDETAIL Table Failed', 'us_english',@nFunc
execute rdt.rdtAddMsg 77815 ,10, '77815^Update ORDERS Table Failed', 'us_english',@nFunc
execute rdt.rdtAddMsg 77816 ,10, '77816^Update rdtScantoTruckFailed', 'us_english',@nFunc
execute rdt.rdtAddMsg 77817 ,10, '77817^Update LoadPlanDetail Failed', 'us_english',@nFunc
execute rdt.rdtAddMsg 77818 ,10, '77818^Update MBOLDetail Failed', 'us_english',@nFunc
execute rdt.rdtAddMsg 77819 ,10, '77819^Update Orders Failed', 'us_english',@nFunc
execute rdt.rdtAddMsg 77820 ,10, '77820^Update Orders Failed', 'us_english',@nFunc
execute rdt.rdtAddMsg 77821 ,10, '77821^Update Orders Failed', 'us_english',@nFunc
execute rdt.rdtAddMsg 77822 ,10, '77822^Update MBOLDetail Failed', 'us_english',@nFunc
execute rdt.rdtAddMsg 77823 ,10, '77823^Update Orders Failed', 'us_english',@nFunc

