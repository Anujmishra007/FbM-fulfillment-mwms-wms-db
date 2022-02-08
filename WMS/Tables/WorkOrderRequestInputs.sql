CREATE TABLE [dbo].[WorkOrderRequestInputs]
(
[WkOrdReqInputsKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequestInputs_WkOrdReqInputsKey] DEFAULT (''),
[WorkOrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequestInputs_WorkOrderKey] DEFAULT (''),
[WkOrdInputsKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequestInputs_WkOrdInputsKey] DEFAULT (''),
[StepNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequestInputs_StepNumber] DEFAULT (''),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequestInputs_StorerKey] DEFAULT (''),
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequestInputs_SKU] DEFAULT (''),
[PackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequestInputs_Packkey] DEFAULT (''),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequestInputs_UOM] DEFAULT (''),
[Qty] [int] NULL CONSTRAINT [DF_WorkOrderRequestInputs_Qty] DEFAULT ((0)),
[QtyRequired] [int] NULL CONSTRAINT [DF_WorkOrderRequestInputs_QtyRequired] DEFAULT ((0)),
[QtyJob] [int] NULL CONSTRAINT [DF_WorkOrderRequestInputs_QtyJob] DEFAULT ((0)),
[QtyReleased] [int] NULL CONSTRAINT [DF_WorkOrderRequestInputs_QtyReleased] DEFAULT ((0)),
[QtyCompleted] [int] NULL CONSTRAINT [DF_WorkOrderRequestInputs_QtyCompleted] DEFAULT ((0)),
[QtyRemaining] [int] NULL CONSTRAINT [DF_WorkOrderRequestInputs_QtyRemaining] DEFAULT ((0)),
[InLocation] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequestInputs_InLocation] DEFAULT (''),
[Wastage] [decimal] (18, 2) NULL CONSTRAINT [DF_WorkOrderRequestInputs_Wastage] DEFAULT ((0.00)),
[Rotation] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderRequestInputs_Rotation] DEFAULT (''),
[MinShelf] [int] NULL CONSTRAINT [DF_WorkOrderRequestInputs_MinShelf] DEFAULT ((0)),
[PullType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderRequestInputs_PullType] DEFAULT ((0)),
[MinQty] [int] NULL CONSTRAINT [DF_WorkOrderRequestInputs_MinQty] DEFAULT ((0)),
[MinUOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderRequestInputs_MinUOM] DEFAULT (''),
[PullQty] [int] NULL CONSTRAINT [DF_WorkOrderRequestInputs_PullQty] DEFAULT ((0)),
[PullUOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderRequestInputs_PullUOM] DEFAULT (''),
[Lottable01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable02] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable04] [datetime] NULL,
[Lottable05] [datetime] NULL,
[NonInvSKU] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequestInputs_NonInvSKU] DEFAULT (''),
[NonInvLocation] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequestInputs_NonInvLocation] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderRequestInputs_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_WorkOrderRequestInputs_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderRequestInputs_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_WorkOrderRequestInputs_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable13] [datetime] NULL,
[Lottable14] [datetime] NULL,
[Lottable15] [datetime] NULL,
[JobKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderRequestInputs_JobKey] DEFAULT (''),
[QtyAddOn] [int] NOT NULL CONSTRAINT [DF_WorkOrderRequestInputs_QtyAddOn] DEFAULT ((0))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/***************************************************************************/
/* Trigger: ntrWorkOrderRequestInputsAdd                                   */
/* Creation Date: 30-Nov-2012                                              */
/* Copyright: LF                                                           */
/* Written by: YTWan                                                       */
/*                                                                         */
/* Purpose:  Update other transactions while WorkOrderJob line is inserted */
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
/* 28-JUL-2015  YTWan    1.1  SOS#318089 - Project Merlion - VAP Add or     */
/*                            Delete Work Order Component (Wan01)          */
/***************************************************************************/
CREATE TRIGGER [dbo].[ntrWorkOrderRequestInputsAdd] ON [dbo].[WorkOrderRequestInputs]
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

   UPDATE WORKORDERREQUESTINPUTS WITH (ROWLOCK)
   SET Qty = CASE WHEN WOR.UOMQty = 0 THEN 0 ELSE (WORQI.Qty/WOR.UOMQty) * WOR.UOMQty END                                                                 
      ,QtyRequired  = ( CASE WHEN WOR.UOMQty = 0 THEN 0 ELSE ((WORQI.Qty/WOR.UOMQty) * WOR.UOMQty) 
                    +  (((WORQI.Qty/WOR.UOMQty) * WOR.UOMQty) * (WORQI.Wastage / 100)) END
                    +    WORQI.QtyAddOn )
      ,QtyRemaining = ( CASE WHEN WOR.UOMQty = 0 THEN 0 ELSE ((WORQI.Qty/WOR.UOMQty) * WOR.UOMQty) END                                                    
                    +    WORQI.QtyAddOn )
      ,EditWho      = SUSER_NAME()
      ,EditDate     = GETDATE()
      ,Trafficcop   = NULL
   FROM INSERTED
   JOIN WORKORDERREQUEST WOR WITH (NOLOCK) ON (INSERTED.WorkOrderKey = WOR.Workorderkey)
   JOIN WORKORDERREQUESTINPUTS WORQI ON (WOR.WorkOrderkey = WORQI.WorkOrderkey) AND (INSERTED.WkOrdReqInputsKey = WORQI.WkOrdReqInputsKey)
   --LEFT JOIN WORKORDERINPUTS   WOI   WITH (NOLOCK) ON (WORQI.WkOrdInputsKey = WOI.WkOrdInputsKey)  -- (Wan01)

   SET @n_err = @@ERROR

   IF @n_err <> 0
   BEGIN
      SET @n_continue= 3
      SET @n_err     = 63700   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
      SET @c_errmsg  = 'NSQL'+CONVERT(CHAR(5),ISNULL(@n_err,0))+': Update Failed On Table WORKORDERREQUESTINPUTS. (ntrWorkOrderRequestUpdate)' 
      GOTO QUIT
   END 

   DECLARE CUR_WO CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT DISTINCT
          INSERTED.WorkOrderkey
   FROM INSERTED 

   OPEN CUR_WO
   
   FETCH NEXT FROM CUR_WO INTO @c_WorkOrderkey

   WHILE @@FETCH_STATUS <> -1  
   BEGIN
      SET @n_PackQty = 0
      IF @c_WorkOrderType = 'I'
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
         FROM WORKORDERREQUESTINPUTS  WORO WITH (NOLOCK) 
         JOIN PACK                    PACK WITH (NOLOCK) ON (WORO.Packkey = PACK.Packkey)
         WHERE WORO.WorkOrderkey = @c_WorkOrderkey
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
         SET @n_err     = 63705   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SET @c_errmsg  = 'NSQL'+CONVERT(CHAR(5),ISNULL(@n_err,0))+': Insert Failed Into Table WORKORDERREQUEST. (ntrWorkOrderRequestInputsAdd)' 
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

      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrWorkOrderRequestInputsAdd'    
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
/* Trigger: ntrWorkOrderRequestInputsDelete                                */
/* Creation Date: 24-Jul-2015                                              */
/* Copyright: LF                                                           */
/* Written by: YTWan                                                       */
/*                                                                         */
/* Purpose:  Delete Job's transaction if delete input component            */
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
CREATE TRIGGER [dbo].[ntrWorkOrderRequestInputsDelete] ON [dbo].[WorkOrderRequestInputs]
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
         , @c_WkOrdReqInputsKey  NVARCHAR(10)
   
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
                               FROM WORKORDERREQUESTINPUTS WORI WITH (NOLOCK) 
                               WHERE WORI.WorkOrderkey = DELETED.WorkOrderkey)
             )
   BEGIN
      SET @n_Continue= 3 
      SET @n_err  = 60070
      SET @c_errmsg = 'Workorder has assigned to Job. Not Allow to delete all workorder inputs.'
                    + '(ntrWorkOrderRequestInputsDelete)'
      GOTO QUIT
   END


   DECLARE CUR_DELINPUT CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT DELETED.WorkOrderkey
         ,DELETED.WkOrdReqInputsKey
   FROM DELETED 

   OPEN CUR_DELINPUT
   
   FETCH NEXT FROM CUR_DELINPUT INTO @c_WorkOrderkey
                                    ,@c_WkOrdReqInputsKey

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
         SET @b_Success = 0  
         EXEC dbo.ispCancJobOperationInput 
                 @c_Jobkey  = @c_Jobkey
               , @c_WorkOrderkey = @c_WorkOrderkey
               , @c_WkOrdReqInputsKey = @c_WkOrdReqInputsKey
               , @b_Success = @b_Success     OUTPUT  
               , @n_Err     = @n_err         OUTPUT   
               , @c_ErrMsg  = @c_errmsg      OUTPUT  

         IF @n_err <> 0  
         BEGIN 
            SET @n_Continue= 3 
            SET @n_err  = 60075
            SET @c_errmsg = 'Execute ispCancJobOperationInput Failed.'
                          + '(' + @c_errmsg + '). (ntrWorkOrderRequestInputsDelete)'
            GOTO QUIT
         END 
         FETCH NEXT FROM CUR_JOB INTO @c_Jobkey
      END
      CLOSE CUR_JOB
      DEALLOCATE CUR_JOB

      FETCH NEXT FROM CUR_DELINPUT INTO @c_WorkOrderkey
                                       ,@c_WkOrdReqInputsKey
   END
   CLOSE CUR_DELINPUT
   DEALLOCATE CUR_DELINPUT
QUIT:
   IF CURSOR_STATUS( 'LOCAL', 'CUR_DELINPUT') in (0 , 1)  
   BEGIN
      CLOSE CUR_DELINPUT
      DEALLOCATE CUR_DELINPUT
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

      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrWorkOrderRequestInputsDelete'    
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
ALTER TABLE [dbo].[WorkOrderRequestInputs] ADD CONSTRAINT [PK_WorkOrderRequestInputs] PRIMARY KEY CLUSTERED ([WkOrdReqInputsKey]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WorkOrderRequestInputs] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WorkOrderRequestInputs] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WorkOrderRequestInputs] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WorkOrderRequestInputs] TO [NSQL]
GO
