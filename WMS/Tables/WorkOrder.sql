CREATE TABLE [dbo].[WorkOrder]
(
[WorkOrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrder_WorkOrderKey] DEFAULT (' '),
[ExternWorkOrderKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrder_ExternWorkOrderKey] DEFAULT (' '),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrder_StorerKey] DEFAULT (' '),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrder_Facility] DEFAULT (' '),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrder_Status] DEFAULT ('0'),
[ExternStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrder_ExternStatus] DEFAULT ('0'),
[Type] [nvarchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrder_Type] DEFAULT (' '),
[Reason] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrder_Reason] DEFAULT (' '),
[TotalPrice] [money] NULL CONSTRAINT [DF_WorkOrder_TotalPrice] DEFAULT ((0)),
[GenerateCharges] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrder_GenerateCharges] DEFAULT ('No'),
[Remarks] [nvarchar] (215) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrder_Remarks] DEFAULT (' '),
[Notes1] [nvarchar] (215) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrder_Notes1] DEFAULT (' '),
[Notes2] [nvarchar] (215) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrder_Notes2] DEFAULT (' '),
[WkOrdUdef1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrder_WkOrdUdef1] DEFAULT (' '),
[WkOrdUdef2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrder_WkOrdUdef2] DEFAULT (' '),
[WkOrdUdef3] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrder_WkOrdUdef3] DEFAULT (' '),
[WkOrdUdef4] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrder_WkOrdUdef4] DEFAULT (' '),
[WkOrdUdef5] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrder_WkOrdUdef5] DEFAULT (' '),
[AddDate] [datetime] NULL CONSTRAINT [DF_WorkOrder_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrder_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_WorkOrder_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrder_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WkOrdUdef6] [datetime] NULL CONSTRAINT [DF_WorkOrder_WkOrdUdef6] DEFAULT (' '),
[WkOrdUdef7] [datetime] NULL CONSTRAINT [DF_WorkOrder_WkOrdUdef7] DEFAULT (' '),
[WkOrdUdef8] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrder_WkOrdUdef8] DEFAULT (' '),
[WkOrdUdef9] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrder_WkOrdUdef9] DEFAULT (' '),
[WkOrdUdef10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrder_WkOrdUdef10] DEFAULT (' ')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/* 14-Jul-2011  KHLim02    1.2   GetRight for Delete log                */

CREATE TRIGGER [dbo].[ntrWorkOrderHeaderDelete]
ON [dbo].[WorkOrder]
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

   DECLARE  @b_Success     int,       -- Populated by calls to stored procedures - was the proc successful?
            @n_err         int,       -- Error number returned by stored procedure or this trigger
            @c_errmsg      NVARCHAR(250), -- Error message returned by stored procedure or this trigger
            @n_continue    int,       -- continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip further processing
            @n_starttcnt   int,       -- Holds the current transaction count
            @n_cnt         int        -- Holds the number of rows affected by the DELETE statement that fired this trigger.
           ,@c_authority   NVARCHAR(1)  -- KHLim02
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
   IF (SELECT count(*) FROM DELETED) =
   (SELECT count(*) FROM DELETED WHERE DELETED.ArchiveCop = '9')
   BEGIN
      SELECT @n_continue = 4
   END

      /* #INCLUDE <TRCONHD1.SQL> */     
   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      SELECT @b_success = 0         --    Start (KHLim02)
      EXECUTE nspGetRight  NULL,             -- facility  
                           NULL,             -- Storerkey  
                           NULL,             -- Sku  
                           'DataMartDELLOG', -- Configkey  
                           @b_success     OUTPUT, 
                           @c_authority   OUTPUT, 
                           @n_err         OUTPUT, 
                           @c_errmsg      OUTPUT  
      IF @b_success <> 1
      BEGIN
         SELECT @n_continue = 3
               ,@c_errmsg = 'ntrWorkOrderHeaderDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'         --    End   (KHLim02)
      BEGIN
         INSERT INTO dbo.WorkOrder_DELLOG ( WorkOrderKey )
         SELECT WorkOrderKey FROM DELETED

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table WorkOrder Failed. (ntrWorkOrderHeaderDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END
      END
   END

      /* #INCLUDE <TRCOND2.SQL> */
   IF @n_continue=3  -- Error Occured - Process And Return
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrWorkOrderHeaderDelete'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
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

/************************************************************************/
/* Trigger: ntrWorkOrderHeaderUpdate                                    */
/* Creation Date: 13-Aug-2007                                           */
/* Copyright: IDS                                                       */
/* Written by: YokeBeen                                                 */
/*                                                                      */
/* Purpose: Handle trigger point of WorkOrder table updates.            */
/*                                                                      */
/* Input Parameters:                                                    */
/*                                                                      */
/* Output Parameters:                                                   */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Called By:  Any related Updates of table WorkOrder.                  */
/*                                                                      */
/* PVCS Version: 1.1                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Date         Author     Ver.  Purposes                               */
/* 25 May 2012  TLTING01   1.0   DM integrity - add update editdate B4  */
/*                               TrafficCop for status < '9'            */ 
/* 28-Oct-2013  TLTING     1.0   Review Editdate column update          */
/* 30-May-2017  YokeBeen   1.1   Revised and moved the trigger points   */
/*                               to a Sub-SP - isp_ITF_ntrWorkOrder.    */
/*                               - (YokeBeen01).                        */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrWorkOrderHeaderUpdate]
ON  [dbo].[WorkOrder]
FOR UPDATE
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

   DECLARE @b_debug int
   SET @b_debug = 0

   DECLARE   
     @b_Success            INT       
   , @n_err                INT       
   , @n_err2               INT       
   , @c_errmsg             NVARCHAR(250) 
   , @n_continue           INT
   , @n_starttcnt          INT
   , @c_preprocess         NVARCHAR(250) 
   , @c_pstprocess         NVARCHAR(250) 
   , @n_cnt                INT      

   DECLARE   
     @c_WorkOrderKey       NVARCHAR(10) 
   , @c_Status             NVARCHAR(10) 
   , @c_StorerKey          NVARCHAR(15) 

   --(YokeBeen01) - START
   DECLARE 
     @c_TriggerName        NVARCHAR(120) 
   , @c_SourceTable        NVARCHAR(60) 
   , @c_ExternStatus       NVARCHAR(10) 
   , @b_ColumnsUpdated     VARBINARY(1000) 

   SET @b_ColumnsUpdated   = COLUMNS_UPDATED() 
   SET @c_TriggerName      = 'ntrWorkOrderHeaderUpdate'
   SET @c_SourceTable      = 'WORKORDER'
   --(YokeBeen01) - END

   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
   IF UPDATE(ArchiveCop)
   BEGIN
      SELECT @n_continue = 4
   END
   
   -- tlting01
   IF EXISTS ( SELECT 1 FROM INSERTED, DELETED 
                WHERE INSERTED.StorerKey =  DELETED.StorerKey
                  AND INSERTED.WorkOrderKey =  DELETED.WorkOrderKey
                  AND ( INSERTED.[Status] < '9' OR DELETED.[Status] < '9')  ) 
         AND ( @n_continue = 1 OR @n_continue = 2 )
         AND NOT UPDATE(EditDate)
	BEGIN 	
	 	UPDATE WORKORDER WITH (ROWLOCK) 
    	   SET EditDate = GETDATE(), 
             EditWho  = SUser_SName(),
             TrafficCop = NULL 
        FROM WORKORDER  
        JOIN INSERTED ON (WORKORDER.StorerKey    = INSERTED.StorerKey
                     AND WORKORDER.WorkOrderKey  = INSERTED.WorkOrderKey) 
        JOIN DELETED  ON (INSERTED.StorerKey     = DELETED.StorerKey
                     AND INSERTED.WorkOrderKey   = DELETED.WorkOrderKey )
       WHERE ( INSERTED.[Status] < '9' OR DELETED.[Status] < '9' )

      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
	 	IF @n_err <> 0
    	BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=68003   
    	   SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),@n_err) + 
                            ': Update Failed On Table WORKORDER. (ntrWorkOrderHeaderUpdate) ( SQLSvr MESSAGE=' + 
                            dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
    	END
	END

   IF UPDATE(TrafficCop)
   BEGIN
      SELECT @n_continue = 4
   END

   IF ( @n_continue = 1 OR @n_continue = 2 ) AND NOT UPDATE(EditDate)
	BEGIN 	
	 	UPDATE WORKORDER WITH (ROWLOCK) 
    	   SET EditDate = GETDATE(), 
             EditWho  = SUser_SName(),
             TrafficCop = NULL 
        FROM WORKORDER  
        JOIN INSERTED ON (WORKORDER.StorerKey = INSERTED.StorerKey
                      AND WORKORDER.WorkOrderKey = INSERTED.WorkOrderKey) 
       WHERE WORKORDER.[Status] = '9'

      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

	 	IF @n_err <> 0
    	BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=68001   
    	   SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),@n_err) + 
                            ': Update Failed On Table WORKORDER. (ntrWorkOrderHeaderUpdate) ( SQLSvr MESSAGE=' + 
                            dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
    	END
	END


   IF @n_continue = 1 OR @n_continue = 2 -- (Trigger Point)
   BEGIN 
/********************************************************/
/* Interface Trigger Points Calling Process - (Start)   */
/********************************************************/
   -- (YokeBeen01) - Start
      DECLARE Cur_WorkOrder_TriggerPoints CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      -- Extract values for required variables
       SELECT DISTINCT INSERTED.WorkOrderKey
         FROM INSERTED 
         JOIN ITFTriggerConfig WITH (NOLOCK) ON ( ITFTriggerConfig.StorerKey = INSERTED.StorerKey )
        WHERE ITFTriggerConfig.SourceTable = @c_SourceTable
          AND ITFTriggerConfig.sValue      = '1'
       UNION 
       SELECT DISTINCT INSERTED.WorkOrderKey 
         FROM INSERTED   
         JOIN ITFTriggerConfig WITH (NOLOCK) ON ( ITFTriggerConfig.StorerKey = 'ALL' )
         JOIN StorerConfig WITH (NOLOCK) ON ( StorerConfig.StorerKey = INSERTED.StorerKey AND 
                                              StorerConfig.ConfigKey = ITFTriggerConfig.ConfigKey AND 
                                              StorerConfig.SValue = '1' )
        WHERE ITFTriggerConfig.SourceTable = @c_SourceTable 
          AND ITFTriggerConfig.sValue      = '1' 

      OPEN Cur_WorkOrder_TriggerPoints  
      FETCH NEXT FROM Cur_WorkOrder_TriggerPoints INTO @c_WorkOrderKey 

      WHILE @@FETCH_STATUS <> -1  
      BEGIN  
         -- Execute SP - isp_ITF_ntrWorkOrderHeader
         EXECUTE dbo.isp_ITF_ntrWorkOrderHeader
                  @c_TriggerName    = @c_TriggerName
                , @c_SourceTable    = @c_SourceTable
                , @c_WorkOrderKey   = @c_WorkOrderKey
                , @b_ColumnsUpdated = @b_ColumnsUpdated 
                , @b_Success        = @b_Success OUTPUT
                , @n_err            = @n_err     OUTPUT
                , @c_errmsg         = @c_errmsg  OUTPUT

         FETCH NEXT FROM Cur_WorkOrder_TriggerPoints INTO @c_WorkOrderKey
      END -- WHILE @@FETCH_STATUS <> -1
      CLOSE Cur_WorkOrder_TriggerPoints
      DEALLOCATE Cur_WorkOrder_TriggerPoints
   -- (YokeBeen01) - End
   END -- IF @n_continue = 1 OR @n_continue = 2 -- (Trigger Point)
/********************************************************/
/* Interface Trigger Points Calling Process - (End)     */
/********************************************************/

	/* #INCLUDE <TRRDA2.SQL> */    
   IF @n_continue=3  -- Error Occured - Process And Return    
   BEGIN    
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT >= @n_starttcnt    
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

      EXECUTE dbo.nsp_logerror @n_err, @c_errmsg, 'ntrWorkOrderHeaderUpdate'    
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
ALTER TABLE [dbo].[WorkOrder] ADD CONSTRAINT [PK_WorkOrder] PRIMARY KEY CLUSTERED ([WorkOrderKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_WORKORDER_ExternWorkOrdKey] ON [dbo].[WorkOrder] ([ExternWorkOrderKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WorkOrder] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WorkOrder] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WorkOrder] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WorkOrder] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'the external workorder status', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'ExternStatus'
GO
EXEC sp_addextendedproperty N'MS_Description', 'this field stores the external Workorder reference number (if any)', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'ExternWorkOrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'key in the facility from which the goods are residing', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'indicate whether charges are to be generated', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'GenerateCharges'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information about workorder.', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'Notes1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'instructions on the Workorder are to be recorded here', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'Notes2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'the reason of the Workorder activities', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'Reason'
GO
EXEC sp_addextendedproperty N'MS_Description', 'any remarks or notes', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'Remarks'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Status', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', 'type the name of the storer whom the goods belong to', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'the total price of the transactions which is computed based on the detail lines', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'TotalPrice'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'key in the Workorder type', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'Type'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Work Order Userdefine 10', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'WkOrdUdef10'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Work Order Userdefine 6', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'WkOrdUdef6'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Work Order Userdefine 7', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'WkOrdUdef7'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Work Order Userdefine 8', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'WkOrdUdef8'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Work Order Userdefine 9', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'WkOrdUdef9'
GO
EXEC sp_addextendedproperty N'MS_Description', 'use the default', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'WorkOrderKey'
GO
