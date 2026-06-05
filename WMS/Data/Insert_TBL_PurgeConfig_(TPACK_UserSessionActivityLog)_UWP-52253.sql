INSERT INTO [dbo].[TBL_PURGECONFIG]
           ([Item]
           ,[TBLName]
           ,[Description]
           ,[Threshold]
           ,[Date_Col]
           ,[Condition]
           ,[PurgeGroup])
     VALUES
           ('TPACK_UserSessionActivityLog'
           ,'API.TPACK_UserSessionActivityLog'
           ,'Purge TouchPack UserSession Activity Log Table'
           ,'7'
           ,'AddDate'
           ,''
           ,'WMS')



