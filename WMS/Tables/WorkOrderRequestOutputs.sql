CREATE TABLE [dbo].[WorkOrderRequestOutputs]
(
[WkOrdReqOutputsKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequestOutputs_WkOrdReqOutputsKey] DEFAULT (''),
[WorkOrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequestOutputs_WorkOrderKey] DEFAULT (''),
[WkOrdOutputsKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequestOutputs_WkOrdOutputsKey] DEFAULT (''),
[StepNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequestOutputs_StepNumber] DEFAULT (''),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequestOutputs_StorerKey] DEFAULT (''),
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequestOutputs_SKU] DEFAULT (''),
[PackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequestOutputs_Packkey] DEFAULT (''),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequestOutputs_UOM] DEFAULT (''),
[OutLocation] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequestOutputs_OutLocation] DEFAULT (''),
[Qty] [int] NULL CONSTRAINT [DF_WorkOrderRequestOutputs_Qty] DEFAULT ((0)),
[QtyCompleted] [int] NULL CONSTRAINT [DF_WorkOrderRequestOutputs_QtyCompleted] DEFAULT ((0)),
[QtyRemaining] [int] NULL CONSTRAINT [DF_WorkOrderRequestOutputs_QtyRemaining] DEFAULT ((0)),
[InventoryStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequestOutputs_InventoryStatus] DEFAULT ('0'),
[NonInvSKU] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequestOutputs_NonInvSKU] DEFAULT (''),
[BillingUOMQty] [int] NULL CONSTRAINT [DF_WorkOrderRequestOutputs_BillingUOMQty] DEFAULT ((0)),
[BillingUOM] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderRequestOutputs_BillingUOM] DEFAULT (''),
[BillingRate] [money] NULL CONSTRAINT [DF_WorkOrderRequestOutputs_BillingRate] DEFAULT ((0.00)),
[PrimaryStorer] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequestOutputs_PrimaryStorer] DEFAULT (''),
[PrimarySKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequestOutputs_PrimarySKU] DEFAULT (''),
[Lottable01Rules] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable02Rules] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable03Rules] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable04Rules] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable05Rules] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderRequestOutputs_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_WorkOrderRequestOutputs_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderRequestOutputs_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_WorkOrderRequestOutputs_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable06Rules] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable07Rules] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable08Rules] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable09Rules] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable10Rules] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable11Rules] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable12Rules] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable13Rules] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable14Rules] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable15Rules] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/***************************************************************************/
/* Trigger: ntrWorkOrderRequestOutputsAdd                                  */
/* Creation Date: 03-Aug-2015                                              */
/* Copyright: LF                                                           */
/* Written by: YTWan                                                       */
/*                                                                         */
/* Purpose: Calc QtyRemaining when Add new Output Line                     */
/*        : SOS#318089 - Project Merlion - VAP Add or Delete               */
/*                       Work Order Component (Wan01)                      */
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
CREATE TRIGGER [dbo].[ntrWorkOrderRequestOutputsAdd] ON [dbo].[WorkOrderRequestOutputs]
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

   
         , @c_WorkOrderkey    NVARCHAR(10)
         , @c_WorkOrderType   NVARCHAR(10)
         , @n_PackQty         FLOAT

   SET @n_Continue  = 1
   SET @n_StartTCnt = @@TRANCOUNT   

   SET @c_WorkOrderType = 'O'

   IF EXISTS( SELECT 1 FROM INSERTED WHERE ArchiveCop = '9')
   BEGIN
      SET @n_continue = 4
      GOTO QUIT
   END

   UPDATE WORKORDERREQUESTOUTPUTS WITH (ROWLOCK)
   SET Qty          = CASE WHEN WOR.UOMQty = 0 THEN 0 ELSE ((WORQO.Qty/WOR.UOMQty) * WOR.UOMQty) END
      ,QtyRemaining = CASE WHEN WOR.UOMQty = 0 THEN 0 ELSE ((WORQO.Qty/WOR.UOMQty) * WOR.UOMQty) END                        
      ,EditWho      = SUSER_NAME()
      ,EditDate     = GETDATE()
      ,Trafficcop   = NULL
   FROM INSERTED
   JOIN WORKORDERREQUEST WOR WITH (NOLOCK) ON (INSERTED.WorkOrderKey = WOR.Workorderkey)
   JOIN WORKORDERREQUESTOUTPUTS WORQO ON  (WOR.WorkOrderkey = WORQO.WorkOrderkey)
                                      AND (INSERTED.WkOrdReqOutputsKey = WORQO.WkOrdReqOutputsKey)
   --LEFT JOIN WORKORDEROUTPUTS   WOO   WITH (NOLOCK) ON (WORQO.WkOrdOutputsKey = WOO.WkOrdOutputsKey)  -- (Wan01)

   SET @n_err = @@ERROR

   IF @n_err <> 0
   BEGIN
      SET @n_continue= 3
      SET @n_err     = 63705   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
      SET @c_errmsg  = 'NSQL'+CONVERT(CHAR(5),ISNULL(@n_err,0))+': Update Failed On Table WORKORDERREQUESTOUTPUTS. (ntrWorkOrderRequestUpdate)' 
      GOTO QUIT
   END 
   DECLARE CUR_WO CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT INSERTED.WorkOrderkey
   FROM INSERTED 

   OPEN CUR_WO
   
   FETCH NEXT FROM CUR_WO INTO @c_WorkOrderkey

   WHILE @@FETCH_STATUS <> -1  
   BEGIN
      SET @n_PackQty = 0
      IF @c_WorkOrderType = 'O'
      BEGIN
         SELECT TOP 1 @n_PackQty = CASE WORO.UOM
                                   WHEN PACK.PACKUOM1 THEN PACK.CaseCnt
                                   WHEN PACK.PACKUOM2 THEN PACK.InnerPack
                                   WHEN PACK.PACKUOM3 THEN 1
                                   WHEN PACK.PACKUOM4 THEN PACK.Pallet
                                   WHEN PACK.PACKUOM5 THEN PACK.Cube
                                   WHEN PACK.PACKUOM6 THEN PACK.GrossWgt
                                   WHEN PACK.PACKUOM7 THEN PACK.NetWgt
                                   WHEN PACK.PACKUOM8 THEN PACK.OtherUnit1
                                   WHEN PACK.PACKUOM9 THEN PACK.OtherUnit2
                                   ELSE 1
                                   END
         FROM WORKORDERREQUESTOUTPUTS WORO WITH (NOLOCK) 
         JOIN PACK                    PACK WITH (NOLOCK) ON (WORO.Packkey = PACK.Packkey)
         WHERE WORO.WorkOrderkey = @c_Workorderkey
      END
    
      UPDATE WORKORDERREQUEST WITH (ROWLOCK)
      SET Qty          = UOMQty * @n_PackQty
         ,QtyRemaining = UOMQtyRemaining * @n_PackQty
         ,PackQty      = CASE WHEN @n_PackQty > 0 THEN @n_PackQty ELSE PackQty END
         ,EditWho      = SUSER_NAME() 
         ,EditDate     = GETDATE()
         ,Trafficcop   = NULL
      WHERE WorkOrderkey = @c_WorkOrderkey
      
      SET @n_err = @@ERROR

      IF @n_err <> 0
      BEGIN
         SET @n_continue= 3
         SET @n_err     = 63710   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SET @c_errmsg  = 'NSQL'+CONVERT(CHAR(5),ISNULL(@n_err,0))+': Insert Failed Into Table WORKORDERREQUEST. (ntrWorkOrderRequestOutputAdd)' 
         GOTO QUIT
      END 

      FETCH NEXT FROM CUR_WO INTO @c_WorkOrderkey
   END
   CLOSE CUR_WO
   DEALLOCATE CUR_WO
QUIT:
   IF CURSOR_STATUS( 'LOCAL', 'CUR_WO') in (0 , 1)  
   BEGIN
      CLOSE CUR_WO
      DEALLOCATE CUR_WO
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

      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrWorkOrderRequestOutputsAdd'    
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
/* Trigger: ntrWorkOrderRequestOutputsDelete                               */
/* Creation Date: 24-Jul-2015                                              */
/* Copyright: LF                                                           */
/* Written by: YTWan                                                       */
/*                                                                         */
/* Purpose:  Delete Job's transaction if delete output component           */
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
CREATE TRIGGER [dbo].[ntrWorkOrderRequestOutputsDelete] ON [dbo].[WorkOrderRequestOutputs]
FOR DELETE
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

         , @c_Jobkey             NVARCHAR(10)
         , @c_WorkOrderkey       NVARCHAR(10)          
         , @c_WkOrdReqOutputsKey NVARCHAR(10)
   
   SET @n_Continue  = 1
   SET @n_StartTCnt = @@TRANCOUNT   

   IF (SELECT COUNT(1) FROM DELETED) = (SELECT COUNT(1) FROM DELETED WHERE DELETED.ArchiveCop = '9')  
   BEGIN
      SET @n_Continue = 4
      GOTO QUIT
   END

   IF EXISTS ( SELECT 1
               FROM DELETED
               JOIN WORKORDERJOB WOJ  WITH (NOLOCK) ON (DELETED.WorkOrderkey = WOJ.WorkOrderkey)
               WHERE WOJ.QtyJob > 0 
               AND NOT EXISTS (SELECT 1 
                               FROM WORKORDERREQUESTOUTPUTS WORO WITH (NOLOCK) 
                               WHERE WORO.WorkOrderkey = DELETED.WorkOrderkey)
             )
   BEGIN
      SET @n_Continue= 3 
      SET @n_err  = 60070
      SET @c_errmsg = 'Workorder has assigned to Job. Not Allow to delete all workorder outputs.'
                    + '(ntrWorkOrderRequestOutputsDelete)'
      GOTO QUIT
   END

   DECLARE CUR_DELOUTPUT CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT DELETED.WorkOrderkey
         ,DELETED.WkOrdReqOutputsKey
   FROM DELETED 

   OPEN CUR_DELOUTPUT
   
   FETCH NEXT FROM CUR_DELOUTPUT INTO @c_WorkOrderkey
                                    , @c_WkOrdReqOutputsKey

   WHILE @@FETCH_STATUS <> -1  
   BEGIN
      DECLARE CUR_JOB CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT WORKORDERJOB.JobKey
      FROM WORKORDERJOB WITH (NOLOCK)
      WHERE WORKORDERJOB.WorkOrderkey = @c_WorkOrderkey

      OPEN CUR_JOB
      
      FETCH NEXT FROM CUR_JOB INTO @c_Jobkey

      WHILE @@FETCH_STATUS <> -1  
      BEGIN
         EXEC dbo.ispCancJobOperationOutput 
              @c_Jobkey  = @c_Jobkey
            , @c_WorkOrderkey = @c_WorkOrderkey
            , @c_WkOrdReqOutputsKey = @c_WkOrdReqOutputsKey
            , @b_Success = @b_Success     OUTPUT  
            , @n_Err     = @n_err         OUTPUT   
            , @c_ErrMsg  = @c_errmsg      OUTPUT  

         IF @n_err <> 0  
         BEGIN 
            SET @n_Continue= 3 
            SET @n_err  = 60075
            SET @c_errmsg = 'Execute ispCancJobOperationOutput Failed.'
                          + '(' + @c_errmsg + '). (ntrWorkOrderRequestOutputsDelete)'
            GOTO QUIT
         END
         FETCH NEXT FROM CUR_JOB INTO @c_Jobkey 
      END
      CLOSE CUR_JOB
      DEALLOCATE CUR_JOB

      FETCH NEXT FROM CUR_DELOUTPUT INTO @c_WorkOrderkey
                                       , @c_WkOrdReqOutputsKey
   END
   CLOSE CUR_DELOUTPUT
   DEALLOCATE CUR_DELOUTPUT
QUIT:
   IF CURSOR_STATUS( 'LOCAL', 'CUR_DELOUTPUT') in (0 , 1)  
   BEGIN
      CLOSE CUR_DELOUTPUT
      DEALLOCATE CUR_DELOUTPUT
   END

   IF CURSOR_STATUS( 'LOCAL', 'CUR_JOB') in (0 , 1)  
   BEGIN
      CLOSE CUR_JOB
      DEALLOCATE CUR_JOB
   END

   /* #INCLUDE <TRRDA2.SQL> */    
   IF @n_Continue=3  -- Error Occured - Process And Return    
   BEGIN    
      SET @b_Success = 0

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

      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrWorkOrderRequestOutputsDelete'    
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR 

      RETURN    
   END    
   ELSE    
   BEGIN  
      SET @b_Success = 1
  
      WHILE @@TRANCOUNT > @n_starttcnt    
      BEGIN    
         COMMIT TRAN    
      END    

      RETURN    
   END      
END
GO
ALTER TABLE [dbo].[WorkOrderRequestOutputs] ADD CONSTRAINT [PK_WorkOrderRequestOutputs] PRIMARY KEY CLUSTERED ([WkOrdReqOutputsKey]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WorkOrderRequestOutputs] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WorkOrderRequestOutputs] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WorkOrderRequestOutputs] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WorkOrderRequestOutputs] TO [NSQL]
GO
