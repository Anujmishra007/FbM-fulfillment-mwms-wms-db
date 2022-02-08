CREATE TABLE [dbo].[WorkOrderDetail]
(
[WorkOrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderDetail_WorkOrderKey] DEFAULT (' '),
[WorkOrderLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderDetail_WorkOrderLineNumber] DEFAULT (' '),
[ExternWorkOrderKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderDetail_ExternWorkOrderKey] DEFAULT (' '),
[ExternLineNo] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderDetail_ExternLineNo] DEFAULT (' '),
[Type] [nvarchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderDetail_Type] DEFAULT (' '),
[Reason] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderDetail_Reason] DEFAULT (' '),
[Unit] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderDetail_Unit] DEFAULT (' '),
[Qty] [int] NOT NULL CONSTRAINT [DF_WorkOrderDetail_Qty] DEFAULT ((0)),
[Price] [money] NOT NULL CONSTRAINT [DF_WorkOrderDetail_Price] DEFAULT ((0)),
[LineValue] [money] NULL CONSTRAINT [DF_WorkOrderDetail_LineValue] DEFAULT ((0)),
[Remarks] [nvarchar] (215) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderDetail_Remarks] DEFAULT (' '),
[WkOrdUdef1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderDetail_WkOrdUdef1] DEFAULT (' '),
[WkOrdUdef2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderDetail_WkOrdUdef2] DEFAULT (' '),
[WkOrdUdef3] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderDetail_WkOrdUdef3] DEFAULT (' '),
[WkOrdUdef4] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderDetail_WkOrdUdef4] DEFAULT (' '),
[WkOrdUdef5] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderDetail_WkOrdUdef5] DEFAULT (' '),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderDetail_Status] DEFAULT ('0'),
[AddDate] [datetime] NULL CONSTRAINT [DF_WorkOrderDetail_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderDetail_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_WorkOrderDetail_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderDetail_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderDetail_StorerKey] DEFAULT (' '),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderDetail_Sku] DEFAULT (' '),
[WkOrdUdef6] [datetime] NULL CONSTRAINT [DF_WorkOrderDetail_WkOrdUdef6] DEFAULT (' '),
[WkOrdUdef7] [datetime] NULL CONSTRAINT [DF_WorkOrderDetail_WkOrdUdef7] DEFAULT (' '),
[WkOrdUdef8] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderDetail_WkOrdUdef8] DEFAULT (' '),
[WkOrdUdef9] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderDetail_WkOrdUdef9] DEFAULT (' '),
[WkOrdUdef10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderDetail_WkOrdUdef10] DEFAULT (' ')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/* 14-Jul-2011  KHLim02    1.2   GetRight for Delete log                */

CREATE TRIGGER [dbo].[ntrWorkOrderDetailDelete]
ON [dbo].[WorkOrderDetail]
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
         INSERT INTO dbo.WorkOrderDetail_DELLOG ( WorkOrderKey, WorkOrderLineNumber )
         SELECT WorkOrderKey, WorkOrderLineNumber FROM DELETED

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table WorkOrder Failed. (ntrWorkOrderDetailDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrWorkOrderDetailDelete'
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
/* Trigger: ntrWorkOrderDetailUpdate                                    */
/* Creation Date: 13-Aug-2007                                           */
/* Copyright: IDS                                                       */
/* Written by: YokeBeen                                                 */
/*                                                                      */
/* Purpose: Handle trigger point of WORKORDERDETAIL table updates.      */
/*                                                                      */
/* Input Parameters:                                                    */
/*                                                                      */
/* Output Parameters:                                                   */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Called By:  Any related Updates of table WORKORDERDETAIL.            */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Date         Author     Purposes                                     */
/* 25 May 2012  TLTING01   DM integrity - add update editdate B4        */
/*                         TrafficCop                                   */ 
/* 28-Oct-2013  TLTING     Review Editdate column update                */
/*                                                                      */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrWorkOrderDetailUpdate]
ON  [dbo].[WorkOrderDetail]
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
     @b_Success            int       
   , @n_err                int       
   , @n_err2               int       
   , @c_errmsg             NVARCHAR(250) 
   , @n_continue           int
   , @n_starttcnt          int
   , @c_preprocess         NVARCHAR(250) 
   , @c_pstprocess         NVARCHAR(250) 
   , @n_cnt                int      

   DECLARE   
     @c_WorkOrderKey       NVARCHAR(10) 
   , @c_Status             NVARCHAR(10) 
--    , @c_StorerKey          NVARCHAR(15) 

   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
   
   IF UPDATE(ArchiveCop)
   BEGIN
      SELECT @n_continue = 4
   END
   
   IF ( @n_continue = 1 OR @n_continue = 2 ) AND NOT UPDATE(EditDate)
	BEGIN 	
	 	UPDATE WORKORDERDETAIL WITH (ROWLOCK) 
    	   SET EditDate = GETDATE(), 
             EditWho = SUser_SName() 
        FROM WORKORDERDETAIL  
        JOIN INSERTED ON (WORKORDERDETAIL.WorkOrderKey = INSERTED.WorkOrderKey 
                      AND WORKORDERDETAIL.WorkOrderLineNumber = INSERTED.WorkOrderLineNumber) 

      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

	 	IF @n_err <> 0
    	BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=68000   
    	   SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),@n_err) + 
                            ': Update Failed On Table WORKORDERDETAIL. (ntrWorkOrderDetailUpdate)' + ' ( ' + 
                            ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
    	END
	END

   IF UPDATE(TrafficCop)
   BEGIN
      SELECT @n_continue = 4
   END

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

      EXECUTE dbo.nsp_logerror @n_err, @c_errmsg, 'ntrWorkOrderDetailUpdate'    
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
ALTER TABLE [dbo].[WorkOrderDetail] ADD CONSTRAINT [PK_WorkOrderDetail] PRIMARY KEY CLUSTERED ([WorkOrderKey], [WorkOrderLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_WORKORDERDETAIL_ExtWorkOrderKey] ON [dbo].[WorkOrderDetail] ([ExternWorkOrderKey], [ExternLineNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WorkOrderDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WorkOrderDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WorkOrderDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WorkOrderDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information. ', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'External Workorder line number', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'ExternLineNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying workorder used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'ExternWorkOrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Computed field where the quantity * price', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'LineValue'
GO
EXEC sp_addextendedproperty N'MS_Description', 'the price of the service', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'Price'
GO
EXEC sp_addextendedproperty N'MS_Description', 'quantity', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'remark per detail line', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'Remarks'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sku', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', N'StorerKey', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'unit of measurement', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'Unit'
GO
EXEC sp_addextendedproperty N'MS_Description', 'detail line user defined', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'WkOrdUdef1'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Work Order Detail Userdefine 10', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'WkOrdUdef10'
GO
EXEC sp_addextendedproperty N'MS_Description', 'detail line user defined', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'WkOrdUdef2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'detail line user defined', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'WkOrdUdef3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'detail line user defined', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'WkOrdUdef4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'detail line user defined', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'WkOrdUdef5'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Work Order Detail Userdefine 6', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'WkOrdUdef6'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Work Order Detail Userdefine 7', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'WkOrdUdef7'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Work Order Detail Userdefine 8', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'WkOrdUdef8'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Work Order Detail Userdefine 9', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'WkOrdUdef9'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying workorder.', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'WorkOrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Workorder transaction line number. Use default', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'WorkOrderLineNumber'
GO
