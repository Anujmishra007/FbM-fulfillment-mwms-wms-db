IF EXISTS ( SELECT 1    
         FROM NSQLCONFIG WITH (NOLOCK)    
         WHERE ConfigKey = 'RepleDelLog' AND    
               NSQLValue = '1'   )
BEGIN
Update NSQLCONFIG
Set NSQLValue = 0
WHERE ConfigKey = 'RepleDelLog'
AND NSQLValue = '1'   
END
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[DEL_REPLENISHMENT]') AND name = N'IX_DEL_Replenishment_RowRef')
BEGIN
CREATE NONCLUSTERED INDEX [IX_DEL_Replenishment_RowRef] ON [dbo].[DEL_REPLENISHMENT] ( 	[RowRef] ASC ) 
END
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
