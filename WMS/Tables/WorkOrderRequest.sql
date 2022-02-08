CREATE TABLE [dbo].[WorkOrderRequest]
(
[WorkOrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequest_WorkOrderKey] DEFAULT (''),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequest_Facility] DEFAULT (''),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequest_Storerkey] DEFAULT (''),
[MasterWorkOrder] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequest_MasterWorkOrder] DEFAULT (''),
[WorkOrderName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequest_WorkOrderName] DEFAULT (''),
[StartDate] [datetime] NULL CONSTRAINT [DF_WorkOrderRequest_StartDate] DEFAULT (getdate()),
[DueDate] [datetime] NULL CONSTRAINT [DF_WorkOrderRequest_DueDate] DEFAULT (getdate()),
[ExternalReference] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderRequest_ExternalReference] DEFAULT (''),
[Qty] [int] NULL CONSTRAINT [DF_WorkOrderRequest_Qty] DEFAULT ((0)),
[QtyJob] [int] NULL CONSTRAINT [DF_WorkOrderRequest_QtyJob] DEFAULT ((0)),
[QtyReleased] [int] NULL CONSTRAINT [DF_WorkOrderRequest_QtyReleased] DEFAULT ((0)),
[QtyCompleted] [int] NULL CONSTRAINT [DF_WorkOrderRequest_QtyCompleted] DEFAULT ((0)),
[QtyRemaining] [int] NULL CONSTRAINT [DF_WorkOrderRequest_QtyRemaining] DEFAULT ((0)),
[WOStatus] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequest_WOStatus] DEFAULT ('0'),
[Priority] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequest_Priority] DEFAULT ('9'),
[WorkStation] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderRequest_WorkStation] DEFAULT (''),
[Notes] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderRequest_Notes] DEFAULT (''),
[UDF1] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequest_UDF1] DEFAULT (''),
[UDF2] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequest_UDF2] DEFAULT (''),
[UDF3] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequest_UDF3] DEFAULT (''),
[UDF4] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequest_UDF4] DEFAULT (''),
[UDF5] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequest_UDF5] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderRequest_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_WorkOrderRequest_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderRequest_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_WorkOrderRequest_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UOMQty] [int] NULL CONSTRAINT [DF_WORKORDERREQUEST_UOMQty] DEFAULT ((0)),
[UOMQtyRemaining] [int] NULL CONSTRAINT [DF_WORKORDERREQUEST_UOMQtyRemaining] DEFAULT ((0)),
[PackQty] [int] NULL CONSTRAINT [DF_WORKORDERREQUEST_PackQty] DEFAULT ((0))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/***************************************************************************/
/* Trigger: ntrWorkOrderRequestDelete                                      */
/* Creation Date: 26-Nov-2012                                              */
/* Copyright: LF                                                           */
/* Written by: YTWan                                                       */
/*                                                                         */
/* Purpose:  Trigger when Delete Work order Request                        */
/*                                                                         */
/* Return Status:                                                          */
/*                                                                         */
/* Usage:                                                                  */
/*                                                                         */
/* Called By: When records Inserted                                        */
/*                                                                         */
/* PVCS Version: 1.0                                                       */
/*                                                                         */
/* Version: 5.4                                                            */
/*                                                                         */
/* Modifications:                                                          */
/* Date         Author   Ver  Purposes                                     */
/***************************************************************************/
CREATE TRIGGER [dbo].[ntrWorkOrderRequestDelete] ON [dbo].[WorkOrderRequest]
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

   DECLARE @n_Continue  INT                     
         , @n_StartTCnt INT            -- Holds the current transaction count    
         , @b_Success   INT            -- Populated by calls to stored procedures - was the proc successful?    
         , @n_err       INT            -- Error number returned by stored procedure or this trigger    
         , @c_errmsg    NVARCHAR(255)  -- Error message returned by stored procedure or this trigger    

   SET @n_Continue  = 1
   SET @n_StartTCnt = @@TRANCOUNT     


   IF (SELECT COUNT(1) FROM DELETED) = (SELECT COUNT(1) FROM DELETED WHERE DELETED.ArchiveCop = '9')  
   BEGIN
      SET @n_Continue = 4
      GOTO QUIT
   END

   IF EXISTS ( SELECT 1 
               FROM DELETED
               WHERE WOStatus = '9')
   BEGIN
      SET @n_continue = 3
      SET @n_err=63701   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
      SET @c_errmsg = 'NSQL'+CONVERT(CHAR(5),ISNULL(@n_err,0))+': Not Allow to delete Completed Work Order. (ntrWorkOrderRequestDelete)'
      GOTO QUIT
   END

   IF EXISTS ( SELECT 1 
               FROM DELETED
               JOIN WORKORDERJOB WITH (NOLOCK) ON (DELETED.WorkOrderKey = WORKORDERJOB.WorkOrderKey)
             )  
   BEGIN
      SET @n_continue = 3
      SET @n_err=63702   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
      SET @c_errmsg = 'NSQL'+CONVERT(CHAR(5),ISNULL(@n_err,0))+': Not Allow to delete Work Order exists in WORKORDERJOB. (ntrWorkOrderRequestDelete)'
      GOTO QUIT
   END


   DELETE WORKORDERREQUESTINPUTS WITH (ROWLOCK) 
   FROM DELETED
   WHERE WORKORDERREQUESTINPUTS.WorkOrderkey = DELETED.WorkOrderkey

   --(Wan) - START
   SET @n_err = @@ERROR

   IF @n_err <> 0
   BEGIN
      SET @n_continue= 3
      SET @n_err     = 63703   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
      SET @c_errmsg  = 'NSQL'+CONVERT(CHAR(5),ISNULL(@n_err,0))+': Delete Failed On Table WORKORDERREQUESTINPUTS. (ntrWorkOrderRequestDelete)' 
      GOTO QUIT
   END 
   --(Wan) - END

   DELETE WORKORDERREQUESTOUTPUTS WITH (ROWLOCK) 
   FROM DELETED
   WHERE WORKORDERREQUESTOUTPUTS.WorkOrderkey = DELETED.WorkOrderkey

   --(Wan) - START
   SET @n_err = @@ERROR

   IF @n_err <> 0
   BEGIN
      SET @n_continue= 3
      SET @n_err     = 63704   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
      SET @c_errmsg  = 'NSQL'+CONVERT(CHAR(5),ISNULL(@n_err,0))+': Delete Failed On Table WORKORDERREQUESTOUTPUTS. (ntrWorkOrderRequestDelete)' 
      GOTO QUIT
   END 
   --(Wan) - END
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

      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrWorkOrderRequestDelete'    
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
/* Trigger: ntrWorkOrderRequestUpdate                                      */
/* Creation Date: 04-Nov-2012                                              */
/* Copyright: LF                                                           */
/* Written by: YTWan                                                       */
/*                                                                         */
/* Purpose:  Update other transactions while WorkOrderJob line is updated  */
/*                                                                         */
/* Return Status:                                                          */
/*                                                                         */
/* Usage:                                                                  */
/*                                                                         */
/* Called By: When records Update                                          */
/*                                                                         */
/* PVCS Version: 1.2                                                       */
/*                                                                         */
/* Version: 5.4                                                            */
/*                                                                         */
/* Modifications:                                                          */
/* Date         Author   Ver  Purposes                                     */
/* 16-JULY-2015  YTWan   1.1  SOS#318089 - VAP Add or Delete Order         */
/*                            Component (Wan01)                            */
/* 26-JAN-2016  YTWan    1.2  SOS#315603 - Project Merlion - VAP SKU       */
/*                            Reservation Strategy - MixSku in 1 Pallet    */
/*                            enhancement                                  */	
/***************************************************************************/
CREATE TRIGGER [dbo].[ntrWorkOrderRequestUpdate] ON [dbo].[WorkOrderRequest] 
FOR UPDATE
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

         , @c_WorkOrderkey    NVARCHAR(10)
         , @c_WorkOrderType   NVARCHAR(10)
         , @n_PackQty         FLOAT

--         , @n_Qty             INT
--         , @n_QtyRemainingDel INT
         , @n_QtyRemaining    INT
--         , @n_QtyReleased     INT
--         , @b_JobExists       INT
   SET @n_Continue  = 1
   SET @n_StartTCnt = @@TRANCOUNT

   SET @c_WorkOrderType = 'O'   
   
   IF UPDATE(ArchiveCop)
   BEGIN
      SET @n_Continue = 4
      GOTO QUIT
   END

   IF ( @n_continue=1 or @n_continue=2 ) AND NOT UPDATE(EditDate)
   BEGIN
      UPDATE WORKORDERREQUEST WITH (ROWLOCK)
      SET EditDate = GETDATE() 
         ,EditWho  = SUSER_SNAME() 
         ,TrafficCop = NULL
      FROM WORKORDERREQUEST
      JOIN DELETED  ON (DELETED.WorkOrderKey = WORKORDERREQUEST.WorkOrderKey)
      JOIN INSERTED ON (DELETED.WorkOrderKey = INSERTED.WorkOrderKey)

      SET @n_err = @@ERROR
      IF @n_err <> 0
      BEGIN
         SET @n_continue = 3
         SET @n_err = 63700  -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table WORKORDERREQUEST. (ntrWorkOrderRequestUpdate)'
                      + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
         GOTO QUIT
      END
   END

   IF UPDATE(TrafficCop)
   BEGIN
      SET @n_Continue = 4
      GOTO QUIT
   END

   --(Wan01) - START
--   UPDATE WORKORDERREQUESTINPUTS WITH (ROWLOCK)
--   SET QtyJob       = WORQI.QtyJob + ((INSERTED.QtyJob - DELETED.QtyJob)*(WORQI.Qty / INSERTED.UOMQty)) 
--      ,QtyRemaining = WORQI.QtyRemaining + ((INSERTED.QtyRemaining - DELETED.QtyRemaining )*(WORQI.Qty / INSERTED.UOMQty))
--      ,QtyReleased  = CASE WHEN WORQI.QtyJob > 0 THEN INSERTED.QtyReleased ELSE 0 END
   UPDATE WORKORDERREQUESTINPUTS WITH (ROWLOCK)
   SET QtyRemaining = CASE WHEN WORQI.QtyAddOn > 0 THEN WORQI.QtyRemaining
                           ELSE WORQI.QtyRemaining + (((INSERTED.QtyRemaining - DELETED.QtyRemaining)/INSERTED.PackQty) 
                             * (WORQI.Qty / INSERTED.UOMQty))
                           END
      ,QtyJob       = WORQI.QtyJob + (((INSERTED.QtyJob - DELETED.QtyJob)/INSERTED.PackQty)
                      * (WORQI.Qty / INSERTED.UOMQty)) 
      ,QtyReleased  = WORQI.QtyReleased + CASE WHEN WORQI.SKU <> '' 
                                               THEN (INSERTED.QtyReleased - DELETED.QtyReleased) 
                                               ELSE 0 END
      ,EditWho      = SUSER_NAME()
      ,EditDate     = GETDATE()
      ,Trafficcop   = NULL
   FROM INSERTED
   JOIN DELETED ON (INSERTED.WorkOrderKey = DELETED.Workorderkey)
   JOIN WORKORDERREQUESTINPUTS WORQI ON (DELETED.WorkOrderkey = WORQI.WorkOrderkey)

   SET @n_err = @@ERROR

   IF @n_err <> 0
   BEGIN
      SET @n_continue= 3
      SET @n_err     = 63705   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
      SET @c_errmsg  = 'NSQL'+CONVERT(CHAR(5),ISNULL(@n_err,0))+': Update Failed On Table WORKORDERREQUESTINPUTS. (ntrWorkOrderRequestUpdate)' 
      GOTO QUIT
   END 

   UPDATE WORKORDERREQUESTOUTPUTS WITH (ROWLOCK)
   SET QtyRemaining = WORQO.QtyRemaining + (((INSERTED.QtyRemaining - DELETED.QtyRemaining)/INSERTED.PackQty)* (WORQO.Qty / INSERTED.UOMQty))
      ,EditWho      = SUSER_NAME()
      ,EditDate     = GETDATE()
      ,Trafficcop   = NULL
   FROM INSERTED
   JOIN DELETED ON (INSERTED.WorkOrderKey = DELETED.Workorderkey)
   JOIN WORKORDERREQUESTOUTPUTS WORQO ON (DELETED.WorkOrderkey = WORQO.WorkOrderkey)

   SET @n_err = @@ERROR

   IF @n_err <> 0
   BEGIN
      SET @n_continue= 3
      SET @n_err     = 63705   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
      SET @c_errmsg  = 'NSQL'+CONVERT(CHAR(5),ISNULL(@n_err,0))+': Update Failed On Table WORKORDERREQUESTINPUTS. (ntrWorkOrderRequestUpdate)' 
      GOTO QUIT
   END 

   UPDATE WORKORDERREQUEST WITH (ROWLOCK)
   SET WOStatus     = CASE WHEN INSERTED.WOStatus = '9' THEN '9'
                           WHEN INSERTED.QtyReleased > 0 AND INSERTED.QtyRemaining = 0 THEN '7'
                           WHEN INSERTED.QtyReleased > 0 AND INSERTED.QtyRemaining > 0 THEN '5'
                           WHEN INSERTED.QtyJob      > 0 THEN '3'
                           WHEN INSERTED.QtyJob      = 0 THEN '0'
                           ELSE INSERTED.WOStatus
                           END
      ,QtyRemaining = INSERTED.UOMQtyRemaining * WOR.PackQty
      ,EditWho      = SUSER_NAME()
      ,EditDate     = GETDATE()
      ,Trafficcop   = NULL
   FROM INSERTED
   JOIN DELETED              ON (INSERTED.WorkOrderKey = DELETED.Workorderkey)
   JOIN WORKORDERREQUEST WOR ON (INSERTED.WorkOrderKey = WOR.Workorderkey)

   SET @n_err = @@ERROR
   IF @n_err <> 0
   BEGIN
      SET @n_continue= 3
      SET @n_err     = 63710   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
      SET @c_errmsg  = 'NSQL'+CONVERT(CHAR(5),ISNULL(@n_err,0))+': Update Failed On Table WORKORDERREQUEST. (ntrWorkOrderRequestUpdate)' 
      GOTO QUIT
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

      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrWorkOrderRequestUpdate'    
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
ALTER TABLE [dbo].[WorkOrderRequest] ADD CONSTRAINT [PK_WorkOrderRequest] PRIMARY KEY CLUSTERED ([WorkOrderKey]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WorkOrderRequest] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WorkOrderRequest] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WorkOrderRequest] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WorkOrderRequest] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Packing Qty', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderRequest', 'COLUMN', N'PackQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UOM Qty for Qty', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderRequest', 'COLUMN', N'UOMQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UOM Qty for Qty Remaining', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderRequest', 'COLUMN', N'UOMQtyRemaining'
GO
