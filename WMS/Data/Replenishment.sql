 SELECT *    
         FROM NSQLCONFIG WITH (NOLOCK)    
         WHERE ConfigKey = 'RepleDelLog' AND    
               NSQLValue = '1'   
BEGIN
Update NSQLCONFIG
Set NSQLValue = 0
WHERE ConfigKey = 'RepleDelLog'
AND NSQLValue = '1'   
END
Create index IX_DEL_Replenishment_RowRef on DEL_Replenishment ( RowRef )
IF NOT EXISTS ( Select 1 from tbl_Purgeconfig (NOLOCK) where Item = 'DEL_REPLENISHMENT' )
BEGIN
INSERT INTO tbl_Purgeconfig  (Item, TBLName, Description, Threshold, Date_Col, Condition, PurgeGroup )
values ( 'DEL_REPLENISHMENT','dbo.DEL_REPLENISHMENT','Purge DEL_REPLENISHMENT',14,'DeleteDate','' ,'WMS' )
END
IF NOT EXISTS ( Select 1 from tbl_Purgeconfig (NOLOCK) where Item = 'REPLENISHKEY' )
BEGIN
INSERT INTO tbl_purgeconfig  ( Item, TBLName,Description,Threshold,Date_Col,Condition,PurgeGroup )
values ( 'REPLENISHKEY','dbo.REPLENISHKEY','Purge REPLENISHKEY', 1,'Adddate','','WMS') 
END
