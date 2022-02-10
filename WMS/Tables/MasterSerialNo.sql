CREATE TABLE [dbo].[MasterSerialNo]
(
[MasterSerialNoKey] [bigint] NOT NULL IDENTITY(1, 1),
[LocationCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MasterSerialNo_LocationCode] DEFAULT (''),
[UnitType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MasterSerialNo_UnitType] DEFAULT (''),
[PartnerType] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MasterSerialNo_PartnerType] DEFAULT (''),
[SerialNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MasterSerialNo_SerialNo] DEFAULT (''),
[ElectronicSN] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MasterSerialNo_ElectronicSN] DEFAULT (''),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MasterSerialNo_Storerkey] DEFAULT (''),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MasterSerialNo_Sku] DEFAULT (''),
[ItemID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MasterSerialNo_ItemID] DEFAULT (''),
[ItemDescr] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MasterSerialNo_ItemDescr] DEFAULT (''),
[ChildQty] [int] NULL CONSTRAINT [DF_MasterSerialNo_ChildQty] DEFAULT ((0)),
[ParentSerialNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MasterSerialNo_ParentSerialNo] DEFAULT (''),
[ParentSku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MasterSerialNo_ParentSku] DEFAULT (''),
[ParentItemID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MasterSerialNo_ParentItemID] DEFAULT (''),
[ParentProdLine] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MasterSerialNo_ParentProdLine] DEFAULT (''),
[VendorSerialNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MasterSerialNo_VendorSerialNo] DEFAULT (''),
[VendorLotNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MasterSerialNo_VendorLotNo] DEFAULT (''),
[LotNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MasterSerialNo_LotNo] DEFAULT (''),
[Revision] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MasterSerialNo_Revision] DEFAULT (''),
[CreationDate] [datetime] NULL,
[Source] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MasterSerialNo_Source] DEFAULT (''),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MasterSerialNo_Status] DEFAULT ('0'),
[Attribute1] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MasterSerialNo_Attribute1] DEFAULT (''),
[Attribute2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MasterSerialNo_Attribute2] DEFAULT (''),
[Attribute3] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MasterSerialNo_Attribute3] DEFAULT (''),
[RequestID] [int] NULL CONSTRAINT [DF_MasterSerialNo_RequestID] DEFAULT ((0)),
[UserDefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MasterSerialNo_UserDefine01] DEFAULT (''),
[UserDefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MasterSerialNo_UserDefine02] DEFAULT (''),
[UserDefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MasterSerialNo_UserDefine03] DEFAULT (''),
[UserDefine04] [datetime] NULL,
[UserDefine05] [datetime] NULL,
[Addwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MasterSerialNo_AddWho] DEFAULT (suser_sname()),
[Adddate] [datetime] NULL CONSTRAINT [DF_MasterSerialNo_AddDate] DEFAULT (getdate()),
[Editwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MasterSerialNo_EditWho] DEFAULT (suser_sname()),
[Editdate] [datetime] NULL CONSTRAINT [DF_MasterSerialNo_EditDate] DEFAULT (getdate()),
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/
/* Trigger: ntrMasterSerialNoAdd                                           */
/* Creation Date: 26-May-2017                                              */
/* Copyright: LF                                                           */
/* Written by: ChewKP                                                      */
/*                                                                         */
/* Purpose: Trigger transaction log to MasterSerialNoTrn table             */
/*        : WMS-1931,                                                      */
/*                                                                         */
/* Return Status:                                                          */
/*                                                                         */
/* Usage:                                                                  */
/*                                                                         */
/* Called By: When records Added                                           */
/*                                                                         */
/* PVCS Version: 1.3                                                       */
/*                                                                         */
/* Version: 5.4                                                            */
/*                                                                         */
/* Modifications:                                                          */
/* Date         Author   Ver  Purposes                                     */
/***************************************************************************/
CREATE TRIGGER [dbo].[ntrMasterSerialNoAdd] ON [dbo].[MasterSerialNo]
FOR INSERT
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue        INT                     
         , @n_StartTCnt       INT            -- Holds the current transaction count    
         , @b_Success         INT            -- Populated by calls to stored procedures - was the proc successful?    
         , @n_err             INT            -- Error number returned by stored procedure or this trigger    
         , @c_errmsg          NVARCHAR(255)  -- Error message returned by stored procedure or this trigger    

 

   SET @n_Continue  = 1
   SET @n_StartTCnt = @@TRANCOUNT   
   
   

   IF EXISTS( SELECT 1 FROM INSERTED WHERE ArchiveCop = '9')
   BEGIN
      SET @n_continue = 4
      GOTO QUIT
   END
   
   IF EXISTS( SELECT 1 FROM INSERTED WHERE TrafficCop = '9' )  
   BEGIN  
      SELECT @n_continue = 4  
      GOTO QUIT
   END  
   
   

   IF (@n_Continue = 1 OR @n_Continue = 2) 
   BEGIN 
      INSERT INTO dbo.MasterSerialNoTrn (
                     	 MasterSerialNoKey   ,TranType         ,LocationCode 	,UnitType 	      ,PartnerType 	,SerialNo 	      ,ElectronicSN 	,Storerkey	
                     	,Sku              	,ItemID 	         ,ItemDescr 	   ,ChildQty	      ,ParentSerialNo	,ParentSku 	   ,ParentItemID 	  
                     	,ParentProdLine	   ,VendorSerialNo	,VendorLotNo 	,LotNo 	         ,Revision	      ,CreationDate	,Source 	      
                     	,Status 	            ,Attribute1 	   ,Attribute2 	,Attribute3       ,RequestID 	      ,UserDefine01 	,UserDefine02 	
                     	,UserDefine03 	      ,UserDefine04 	   ,UserDefine05 	 )
      SELECT MasterSerialNoKey   ,'DP'             ,LocationCode 	,UnitType 	      ,PartnerType 	   ,SerialNo 	      ,ElectronicSN 	,Storerkey	
            ,Sku              	,ItemID 	         ,ItemDescr 	   ,ChildQty	      ,ParentSerialNo	,ParentSku 	   ,ParentItemID 	  
            ,ParentProdLine	   ,VendorSerialNo	,VendorLotNo 	,LotNo 	         ,Revision	      ,CreationDate	,Source 	      
            ,Status 	            ,Attribute1 	   ,Attribute2 	,Attribute3       ,RequestID 	      ,UserDefine01 	,UserDefine02 	
            ,UserDefine03 	      ,UserDefine04 	   ,UserDefine05  
      FROM INSERTED
      
      IF @@ERROR <> 0 
      BEGIN
          SELECT @n_continue = 3
                ,@n_err = 63210
          SELECT @c_errmsg = "NSQL"+CONVERT(CHAR(5) ,@n_err)+
                 ": Insert into MasterSerialNoTrn Failed - Insert Failed. (ntrMasterSerialNoAdd)"
      END
      
   END
   

QUIT:
--   IF CURSOR_STATUS( 'LOCAL', 'CUR_JOB') in (0 , 1)  
--   BEGIN
--      CLOSE CUR_JOB
--      DEALLOCATE CUR_JOB
--   END

--   IF CURSOR_STATUS( 'LOCAL', 'CUR_JOBOP') in (0 , 1)  
--   BEGIN
--      CLOSE CUR_JOBOP
--      DEALLOCATE CUR_JOBOP
--   END

   /* #INCLUDE <TRRDA2.SQL> */    
   IF @n_Continue=3  -- Error Occured - Process And Return    
   BEGIN    
      IF @@TRANCOUNT = 1 and @@TRANCOUNT >= @n_starttcnt    
      BEGIN    
         ROLLBACK TRAN    
      END    
      ELSE    
      BEGIN    
         WHILE @@TRANCOUNT > @n_starttcnt    
         BEGIN    
            COMMIT TRAN    
         END     
      END    

      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrMasterSerialNoAdd'    
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR  

      RETURN    
   END    
   ELSE    
   BEGIN    
      WHILE @@TRANCOUNT > @n_starttcnt    
      BEGIN    
         COMMIT TRAN    
      END    

      RETURN    
   END      
END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/
/* Trigger: ntrMasterSerialNoDelete                                        */
/* Creation Date: 29-May-2017                                              */
/* Copyright: LF                                                           */
/* Written by: ChewKP                                                      */
/*                                                                         */
/* Purpose:                                                                */
/*                                                                         */
/* Return Status:                                                          */
/*                                                                         */
/* Usage:                                                                  */
/*                                                                         */
/* Called By: When records deleted                                         */
/*                                                                         */
/* PVCS Version: 1.1                                                       */
/*                                                                         */
/* Version: 5.4                                                            */
/*                                                                         */
/* Modifications:                                                          */
/* Date         Author   Ver  Purposes                                     */
/* 29-May-2017  ChewKP   1.1  WMS-1931 - Created                           */
/***************************************************************************/

CREATE TRIGGER [dbo].[ntrMasterSerialNoDelete] ON [dbo].[MasterSerialNo] 
FOR DELETE
AS
BEGIN
   IF @@ROWCOUNT = 0  
   BEGIN
      RETURN
   END
   
   

   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue     INT                     
         , @n_StartTCnt    INT            -- Holds the current transaction count    
         , @b_Success      INT            -- Populated by calls to stored procedures - was the proc successful?    
         , @n_err          INT            -- Error number returned by stored procedure or this trigger    
         , @c_errmsg       NVARCHAR(255)  -- Error message returned by stored procedure or this trigger    
        

   SET @n_Continue      = 1
   SET @n_StartTCnt     = @@TRANCOUNT     

   IF (SELECT COUNT(1) FROM DELETED) = (SELECT COUNT(1) FROM DELETED WHERE DELETED.ArchiveCop = '9')  
   BEGIN
      SET @n_Continue = 4
      GOTO QUIT
   END
   
   IF (@n_Continue = 1 OR @n_Continue = 2) 
   BEGIN 
      INSERT INTO dbo.MasterSerialNoTrn (
                     	 MasterSerialNoKey   ,TranType         ,LocationCode 	,UnitType 	      ,PartnerType 	,SerialNo 	      ,ElectronicSN 	,Storerkey	
                     	,Sku              	,ItemID 	         ,ItemDescr 	   ,ChildQty	      ,ParentSerialNo	,ParentSku 	   ,ParentItemID 	  
                     	,ParentProdLine	   ,VendorSerialNo	,VendorLotNo 	,LotNo 	         ,Revision	      ,CreationDate	,Source 	      
                     	,Status 	            ,Attribute1 	   ,Attribute2 	,Attribute3       ,RequestID 	      ,UserDefine01 	,UserDefine02 	
                     	,UserDefine03 	      ,UserDefine04 	   ,UserDefine05 	 )
      SELECT MasterSerialNoKey   ,'WD'             ,LocationCode 	,UnitType 	      ,PartnerType 	   ,SerialNo 	      ,ElectronicSN 	,Storerkey	
            ,Sku              	,ItemID 	         ,ItemDescr 	   ,ChildQty	      ,ParentSerialNo	,ParentSku 	   ,ParentItemID 	  
            ,ParentProdLine	   ,VendorSerialNo	,VendorLotNo 	,LotNo 	         ,Revision	      ,CreationDate	,Source 	      
            ,Status 	            ,Attribute1 	   ,Attribute2 	,Attribute3       ,RequestID 	      ,UserDefine01 	,UserDefine02 	
            ,UserDefine03 	      ,UserDefine04 	   ,UserDefine05 
      FROM DELETED
      
      IF @@ERROR <> 0 
      BEGIN
          SELECT @n_continue = 3
                ,@n_err = 63320
          SELECT @c_errmsg = "NSQL"+CONVERT(CHAR(5) ,@n_err)+
                 ": Insert into MasterSerialNoTrn Failed - Insert Failed. (ntrMasterSerialNoUpdate)"
      END
   END
QUIT:
   /* #INCLUDE <TRRDA2.SQL> */    
   IF @n_Continue=3  -- Error Occured - Process And Return    
   BEGIN    
      IF @@TRANCOUNT = 1 and @@TRANCOUNT >= @n_starttcnt    
      BEGIN    
         ROLLBACK TRAN    
      END    
      ELSE    
      BEGIN    
         WHILE @@TRANCOUNT > @n_starttcnt    
         BEGIN    
            COMMIT TRAN    
         END     
      END    

      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrMasterSerialNoDelete'    
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR  

 
      RETURN    
   END    
   ELSE    
   BEGIN    
      WHILE @@TRANCOUNT > @n_starttcnt    
      BEGIN    
         COMMIT TRAN    
      END    

      RETURN    
   END      
END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/***************************************************************************/
/* Trigger: ntrMasterSerialNoUpdate                                        */
/* Creation Date: 29-May-2017                                              */
/* Copyright: LF                                                           */
/* Written by: ChewKP                                                      */
/*                                                                         */
/* Purpose:                                                                */
/*                                                                         */
/* Return Status:                                                          */
/*                                                                         */
/* Usage:                                                                  */
/*                                                                         */
/* Called By: When records Updated                                         */
/*                                                                         */
/* PVCS Version: 1.2                                                       */
/*                                                                         */
/* Version: 5.4                                                            */
/*                                                                         */
/* Modifications:                                                          */
/* Date         Author   Ver  Purposes                                     */
/* 29-May-2017  ChewKP   1.1  WMS-1931 - Created                           */
/***************************************************************************/
CREATE TRIGGER [dbo].[ntrMasterSerialNoUpdate] ON [dbo].[MasterSerialNo] 
FOR UPDATE
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue           INT                     
         , @n_StartTCnt          INT            -- Holds the current transaction count    
         , @b_Success            INT            -- Populated by calls to stored procedures - was the proc successful?    
         , @n_err                INT            -- Error number returned by stored procedure or this trigger    
         , @c_errmsg             NVARCHAR(255)  -- Error message returned by stored procedure or this trigger    

   
   SET @n_Continue  = 1
   SET @n_StartTCnt = @@TRANCOUNT   
   
    
   IF UPDATE(ArchiveCop)
   BEGIN
      SET @n_Continue = 4
      GOTO QUIT
   END
   
   IF UPDATE(TrafficCop)     
   BEGIN
      SELECT @n_continue = 4
      GOTO QUIT
   END

   
   IF (@n_Continue = 1 OR @n_Continue = 2) 
   BEGIN 
      INSERT INTO dbo.MasterSerialNoTrn (
                     	 MasterSerialNoKey   ,TranType         ,LocationCode 	,UnitType 	      ,PartnerType 	,SerialNo 	      ,ElectronicSN 	,Storerkey	
                     	,Sku              	,ItemID 	         ,ItemDescr 	   ,ChildQty	      ,ParentSerialNo	,ParentSku 	   ,ParentItemID 	  
                     	,ParentProdLine	   ,VendorSerialNo	,VendorLotNo 	,LotNo 	         ,Revision	      ,CreationDate	,Source 	      
                     	,Status 	            ,Attribute1 	   ,Attribute2 	,Attribute3       ,RequestID 	      ,UserDefine01 	,UserDefine02 	
                     	,UserDefine03 	      ,UserDefine04 	   ,UserDefine05 	 )
      SELECT MasterSerialNoKey   ,'AJ'             ,LocationCode 	,UnitType 	      ,PartnerType 	   ,SerialNo 	      ,ElectronicSN 	,Storerkey	
            ,Sku              	,ItemID 	         ,ItemDescr 	   ,ChildQty	      ,ParentSerialNo	,ParentSku 	   ,ParentItemID 	  
            ,ParentProdLine	   ,VendorSerialNo	,VendorLotNo 	,LotNo 	         ,Revision	      ,CreationDate	,Source 	      
            ,Status 	            ,Attribute1 	   ,Attribute2 	,Attribute3       ,RequestID 	      ,UserDefine01 	,UserDefine02 	
            ,UserDefine03 	      ,UserDefine04 	   ,UserDefine05 
      FROM INSERTED
      
      IF @@ERROR <> 0 
      BEGIN
          SELECT @n_continue = 3
                ,@n_err = 63220
          SELECT @c_errmsg = "NSQL"+CONVERT(CHAR(5) ,@n_err)+
                 ": Insert into MasterSerialNoTrn Failed - Insert Failed. (ntrMasterSerialNoUpdate)"
      END
   END
QUIT:
--   IF CURSOR_STATUS( 'LOCAL', 'CUR_JOB') in (0 , 1)  
--   BEGIN
--      CLOSE CUR_JOB
--      DEALLOCATE CUR_JOB
--   END

   IF CURSOR_STATUS( 'LOCAL', 'CUR_JOBWO') in (0 , 1)  
   BEGIN
      CLOSE CUR_JOBWO
      DEALLOCATE CUR_JOBWO
   END
   /* #INCLUDE <TRRDA2.SQL> */    
   IF @n_Continue=3  -- Error Occured - Process And Return    
   BEGIN    
      IF @@TRANCOUNT = 1 and @@TRANCOUNT >= @n_starttcnt    
      BEGIN    
         ROLLBACK TRAN    
      END    
      ELSE    
      BEGIN    
         WHILE @@TRANCOUNT > @n_starttcnt    
         BEGIN    
            COMMIT TRAN    
         END     
      END    

      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrMasterSerialNoUpdate'    
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR 

      RETURN    
   END    
   ELSE    
   BEGIN    
      WHILE @@TRANCOUNT > @n_starttcnt    
      BEGIN    
         COMMIT TRAN    
      END    

      RETURN    
   END      
END
GO
ALTER TABLE [dbo].[MasterSerialNo] ADD CONSTRAINT [PK__MasterSe__1EE8ACD625D8D096] PRIMARY KEY CLUSTERED ([MasterSerialNoKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_MasterSerialNo_Serailno] ON [dbo].[MasterSerialNo] ([SerialNo], [Storerkey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_MasterSerialNo_SkuParentSN] ON [dbo].[MasterSerialNo] ([Storerkey], [Sku], [ParentSerialNo]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MasterSerialNo] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[MasterSerialNo] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[MasterSerialNo] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[MasterSerialNo] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Master Serial Number', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date in which the load is created', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'Adddate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'Addwho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Update to ''9'' for archiving purpose', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Attribute 1', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'Attribute1'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Attribute 2', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'Attribute2'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Attribute 3', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'Attribute3'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Child Qty', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'ChildQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Serial # Creation Date', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'CreationDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'Editdate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'Editwho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Electronic Serial #', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'ElectronicSN'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Item Description', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'ItemDescr'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Item ID', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'ItemID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Location Code', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'LocationCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Lot Number', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'LotNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Master Serial Number Key', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'MasterSerialNoKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parent Item ID', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'ParentItemID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parent Product Line', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'ParentProdLine'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parent Serial Number', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'ParentSerialNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parent Sku', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'ParentSku'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Partner Type', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'PartnerType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Request ID', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'RequestID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Revision', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'Revision'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Serial Number', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'SerialNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sku ', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Source', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'Source'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Serial # Status', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storerkey', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unit Type', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'UnitType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 01', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'UserDefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 02', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'UserDefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 03', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'UserDefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 04', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'UserDefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 05', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'UserDefine05'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Vendor Lot Number', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'VendorLotNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Vendor Serial Number', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'VendorSerialNo'
GO
