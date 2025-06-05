SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Stored Procedure: mspPARLSTD                                         */
/* Creation Date: 2025-04-30                                            */
/* Copyright: Maersk Logistics                                          */
/* Written by: AYD                                                      */
/*                                                                      */
/* Purpose: UWP-31046 - FCR-2403 - ASN Release Putaway Task             */
/*                                                                      */
/* Input Parameters:  @c_ReceiptKey                                     */
/*                                                                      */
/* Output Parameters:  @b_Success                                       */
/*                   , @n_err                                           */
/*                   , @c_errmsg                                        */
/* Return Status:  None                                                 */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Local Variables:                                                     */
/*                                                                      */
/* Called By: isp_ASNReleasePATask_Wrapper                              */
/*                                                                      */
/* Version: 1.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 2025-04-30  AYD      1.0   UWP-31046 - FCR-2403 -                    */
/*                            ASN Release Putaway Task                  */
/************************************************************************/

CREATE OR ALTER PROC dbo.mspPARLSTD
   @c_ReceiptKey  NVARCHAR(10) = ''
,  @b_Success     INT          = 1  OUTPUT
,  @n_Err         INT          = 0  OUTPUT
,  @c_Errmsg      NVARCHAR(250)= '' OUTPUT
,  @b_Debug       INT          = 0
AS
BEGIN
   SET NOCOUNT ON       -- SQL 2005 Standard
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue           INT            = 1
         , @n_StartTCnt          INT            = @@TRANCOUNT
         , @n_NoOfTasks          INT            = 0
         , @n_RowID              INT            = 0         

         , @c_Facility           NVARCHAR(5)    = ''
         , @c_Storerkey          NVARCHAR(15)   = ''
         , @c_ASNStatus          NVARCHAR(10)   = ''
         , @c_Sku                NVARCHAR(20)   = ''
         , @c_Lot                NVARCHAR(10)   = ''
         , @n_QtyReceived        INT            = 0
         , @n_NoOfLoc            INT            = 0

         , @c_TaskDetailKey      NVARCHAR(10)   = ''
         , @c_TaskType           NVARCHAR(10)   = 'PAF'
         , @c_UOM                NVARCHAR(10)   = '1'
         , @c_SourceType         NVARCHAR(30)   = 'mspPARLSTD'
         , @c_PickMethod         NVARCHAR(10)   = 'FP'
         , @c_FromID             NVARCHAR(18)   = ''
         , @c_FromLoc            NVARCHAR(10)   = ''
         , @c_ToLoc              NVARCHAR(10)   = ''
         , @c_FinalLoc           NVARCHAR(10)   = ''
         , @c_FromLogicalLoc     NVARCHAR(10)   = ''
         , @c_ToLogicalLoc       NVARCHAR(10)   = ''
         , @c_Areakey            NVARCHAR(10)   = ''   

         , @c_ASNPATask_OP5      NVARCHAR(1000) = ''
 
         , @CUR_PAID             CURSOR
  
   WHILE @@TRANCOUNT > 0
   BEGIN
      COMMIT TRAN
   END

   SELECT @c_Facility = r.Facility
         ,@c_Storerkey= r.StorerKey
         ,@c_ASNStatus= r.ASNStatus
   FROM Receipt r (NOLOCK)
   WHERE r.ReceiptKey = @c_ReceiptKey
   
   IF @c_ASNStatus < '9' -- check Receipt.ASNStatus = '9' then able to release PA task. 
   BEGIN
      SET @n_Continue = 3
      SET @n_Err = 60110
      SET @c_Errmsg = 'NSQL'+CONVERT(CHAR(5),@n_err)+': ASN has not closed yet. (mspPARLSTD)'
      GOTO QUIT_SP
   END

   SELECT @c_ASNPATask_OP5 = gr.Option5
   FROM dbo.fnc_GetRight2(@c_Facility, @c_Storerkey, '', 'ASNReleasePATask_SP') gr

   SET @c_TaskType = 'PAF'
   SELECT @c_TaskType = dbo.fnc_GetParamValueFromString('@c_TaskType', @c_ASNPATask_OP5, @c_TaskType) --tasktype is setup at Storerconfig.option5, Use dbo.fnc_GetParamValueFromString to get the Parameters value setup at option5. 

   SET @CUR_PAID = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT rd.ReceiptKey
         ,rd.StorerKey
         ,Sku = MIN(rd.Sku)
         ,rd.ToLoc
         ,rd.ToID
         ,QtyReceived = SUM(rd.QtyReceived)
   FROM dbo.RECEIPTDETAIL rd (NOLOCK)
   JOIN LOTxLOCxID lli (NOLOCK) ON lli.StorerKey = rd.StorerKey
                                AND lli.Loc = rd.ToLoc
                                AND lli.ID  = rd.ToID
   LEFT OUTER JOIN TaskDetail td (NOLOCK) ON  td.FromLoc = rd.ToLoc
                                          AND td.FromID  = rd.ToID
                                          AND td.Storerkey = rd.Storerkey
                                          AND td.TaskType  = @c_TaskType 
                                          AND td.Sourcekey = rd.ReceiptKey
   WHERE rd.ReceiptKey = @c_ReceiptKey
   AND   rd.ToID > ''
   AND   rd.FinalizeFlag = 'Y' -- able to release tasks after finalization
   AND   rd.QtyReceived > 0
   AND   lli.Qty > 0
   GROUP BY rd.ReceiptKey
         ,  rd.StorerKey
         ,  rd.ToLoc
         ,  rd.ToID
   HAVING COUNT(1) = SUM(CASE WHEN ISNULL(td.[Status],'X') = 'X' THEN 1 ELSE 0 END) --the purpose is to meet following scenario: able to gen task for the particular LPN no matter how many times ops cancelled that LPN tasks
   ORDER BY rd.ReceiptKey
         ,  rd.ToID

   OPEN @CUR_PAID 

   FETCH NEXT FROM @CUR_PAID INTO @c_ReceiptKey, @c_Storerkey, @c_Sku 
                                 ,@c_FromLoc, @c_FromID, @n_QtyReceived

   WHILE @@FETCH_STATUS <> -1
   BEGIN
      SET @c_ToLoc    = ''
      SET @c_FinalLoc = ''
      SET @c_Areakey  = ''

      IF @n_Continue = 1
      BEGIN
         BEGIN TRAN

         EXECUTE nspg_GetKey
           @KeyName     = 'TaskDetailKey'
         , @fieldlength = 10
         , @keystring   = @c_TaskDetailKey OUTPUT
         , @b_Success   = @b_success       OUTPUT
         , @n_err       = @n_err           OUTPUT
         , @c_errmsg    = @c_errmsg        OUTPUT

         IF NOT @b_success = 1
         BEGIN
            SET @n_Continue = 3
            GOTO QUIT_SP
         END

         IF @n_Continue = 1
         BEGIN
            SELECT TOP 1 @c_Areakey = a.AreaKey
            FROM dbo.LOC l (NOLOCK)
            JOIN AreaDetail a (NOLOCK) ON a.PutawayZone = l.PutawayZone
            WHERE Loc = @c_ToLoc
            ORDER BY a.AreaKey

            SET @c_Lot = ''
            SELECT @c_Lot = MIN (lli.Lot)
            FROM LOTxLOCxID lli (NOLOCK)
            WHERE lli.Storerkey = @c_Storerkey
            AND   lli.Loc = @c_FromLoc
            AND   lli.ID  = @c_FromID
            GROUP BY lli.Storerkey
                  ,  lli.Loc
                  ,  lli.ID

            SET @n_NoOfTasks = @n_NoOfTasks + 1

            IF @b_Debug = 1
            BEGIN
               PRINT "Inserting TASKDETAIL: 
               @c_TaskDetailKey="+@c_TaskDetailKey+",
               @c_TaskType="+@c_TaskType+",
               @c_Lot="+@c_Lot+",
               @c_UOM="+@c_UOM+",
               @c_FromLoc="+@c_FromLoc+",
               @c_FromID="+@c_FromID+",
               @c_ToLoc="+@c_ToLoc+",
               @c_FinalLoc="+@c_FinalLoc+",
               @c_FromLogicalLoc="+@c_FromLogicalLoc+",
               @c_ToLogicalLoc="+@c_ToLogicalLoc+",
               @c_Areakey="+@c_Areakey+",
               @c_PickMethod="+@c_PickMethod+",
               @c_SourceType="+@c_SourceType+",
               @c_ReceiptKey="+@c_ReceiptKey+", 
               @c_Storerkey="+@c_Storerkey+", 
               @c_Sku="+@c_Sku+",
               @c_FromLoc="+@c_FromLoc+", 
               @c_FromID="+@c_FromID+", 
               @n_QtyReceived="+CAST(@n_QtyReceived AS VARCHAR(10))
            END

            INSERT INTO dbo.TASKDETAIL
                   (    TaskDetailKey
                     ,  TaskType
                     ,  Storerkey
                     ,  Sku
                     ,  Lot
                     ,  UOM
                     ,  UOMQty
                     ,  Qty
                     ,  Fromloc
                     ,  LogicalFromLoc
                     ,  FromID
                     ,  ToLoc
                     ,  LogicalToLoc
                     ,  ToID
                     ,  FinalLoc
                     ,  FinalID
                     ,  PickMethod
                     ,  [Status]
                     ,  [Priority]
                     ,  SourcePriority
                     ,  SourceType
                     ,  SourceKey
                     ,  SystemQty
                     ,  AreaKey
                     ,  Message01
                     ,  Message02
                     ,  Message03
                     ,  PendingMoveIn
                   )
            VALUES (    @c_TaskdetailKey
                     ,  @c_TaskType 
                     ,  @c_Storerkey
                     ,  @c_Sku
                     ,  @c_Lot
                     ,  @c_UOM
                     ,  @n_QtyReceived
                     ,  @n_QtyReceived
                     ,  @c_FromLoc
                     ,  @c_FromLoc
                     ,  @c_FromID
                     ,  @c_ToLoc
                     ,  @c_ToLoc
                     ,  ''
                     ,  @c_FinalLoc
                     ,  ''
                     ,  @c_PickMethod
                     ,  '0'
                     ,  '5'
                     ,  '9'
                     ,  @c_SourceType
                     ,  @c_Receiptkey
                     ,  @n_QtyReceived
                     ,  @c_Areakey
                     ,  ''
                     ,  ''
                     ,  ''
                     ,  0
                   )

            IF @@ERROR <> 0
            BEGIN 
               SET @n_Continue = 3
               SET @c_ErrMsg   =  ERROR_MESSAGE()
            END
 
            IF @n_Continue = 3 
            BEGIN
               IF @@ROWCOUNT > 0
               BEGIN
                  ROLLBACK TRAN
               END
            END
            ELSE IF @n_Continue = 1 
            BEGIN
               IF @@ROWCOUNT > 0
               BEGIN
                  COMMIT TRAN
               END
            END
         END
      END

      FETCH NEXT FROM @CUR_PAID INTO @c_ReceiptKey, @c_Storerkey, @c_Sku 
                                    ,@c_FromLoc, @c_FromID, @n_QtyReceived
   END
   CLOSE @CUR_PAID
   DEALLOCATE @CUR_PAID

   SET @n_Continue = 1
   QUIT_SP:

   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      SELECT @b_success = 0
      IF @@TRANCOUNT = 1 and @@TRANCOUNT > @n_StartTCnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartTCnt
         BEGIN
            COMMIT TRAN
         END
      END
      execute nsp_logerror @n_err, @c_errmsg, 'mspPARLSTD'
   END
   ELSE
   BEGIN
      IF @n_NoOfTasks > 0 
      BEGIN
         SET @c_errmsg = 'Total PAF Task: ' +CONVERT(NVARCHAR(5), @n_NoOfTasks)+ ' released sucessfully.'
      END
      ELSE IF @n_NoOfTasks = 0 
      BEGIN
         SET @c_errmsg = 'No PAF Task released.'
      END
 
      SET @b_success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END

   WHILE @@TRANCOUNT < @n_StartTCnt
   BEGIN
      BEGIN TRAN
   END
END