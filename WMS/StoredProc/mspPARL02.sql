SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure: mspPARL02                                          */
/* Creation Date: 2026-03-06                                            */
/* Copyright: Maersk Logistics                                          */
/* Written by: AYD                                                      */
/*                                                                      */
/* Purpose:  FCR-10206 - SAU DAMMAM Putaway Strategy                    */
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
/* 2026-03-05  Wan      1.0   Created                                   */
/* 2026-03-27  Wan      1.0   Fixed                                     */
/************************************************************************/
CREATE OR ALTER PROC [dbo].[mspPARL02]
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

         , @c_Facility           NVARCHAR(5)    = ''
         , @c_Storerkey          NVARCHAR(15)   = ''
         , @c_ASNStatus          NVARCHAR(10)   = ''

         , @b_ManualBreak        BIT            = 1                                 --2027-03-27
         , @n_RowCount           INT            = 0 
         , @n_GrpNo              INT            = 0 
         , @n_LPNLeftToFulfill   INT            = 0 
         , @n_NoOfTasks          INT            = 0

         , @c_ReceiptLineNumber  NVARCHAR(5)    = ''
         , @c_Sku                NVARCHAR(20)   = ''
         , @c_Packkey            NVARCHAR(10)   = ''
         , @c_Lot                NVARCHAR(10)   = ''
         , @c_Lottable01         NVARCHAR(18)   = ''
         , @c_Lottable02         NVARCHAR(18)   = ''
         , @c_Lottable03         NVARCHAR(18)   = ''
         , @dt_Lottable04        DATETIME       = NULL
         , @dt_Lottable05        DATETIME       = NULL
         , @c_Lottable06         NVARCHAR(36)   = ''
         , @c_Lottable07         NVARCHAR(36)   = ''
         , @c_Lottable08         NVARCHAR(36)   = ''
         , @c_Lottable09         NVARCHAR(36)   = ''
         , @c_Lottable10         NVARCHAR(36)   = ''
         , @c_Lottable11         NVARCHAR(36)   = ''
         , @c_Lottable12         NVARCHAR(36)   = ''
         , @dt_Lottable13        DATETIME       = NULL
         , @dt_Lottable14        DATETIME       = NULL
         , @dt_Lottable15        DATETIME       = NULL
         , @n_PutawayCapacity    INT            = 0 
         , @n_QtyReceived        INT            = 0 
         , @n_NoOfLPN            INT            = 0
         , @n_AvailablePASlot    INT            = 0

         , @c_TaskDetailKey      NVARCHAR(10)   = ''
         , @c_TaskType           NVARCHAR(10)   = 'PAF'
         , @c_UOM                NVARCHAR(10)   = '1'
         , @c_SourceType         NVARCHAR(30)   = 'mspPARL02'
         , @c_PickMethod         NVARCHAR(10)   = 'FP'
         , @c_FromID             NVARCHAR(18)   = ''
         , @c_FromLoc            NVARCHAR(10)   = ''
         , @c_ToLoc              NVARCHAR(10)   = ''
         , @c_FinalLoc           NVARCHAR(10)   = ''
         , @c_FromLogicalLoc     NVARCHAR(10)   = ''
         , @c_ToLogicalLoc       NVARCHAR(10)   = ''
         , @c_Areakey            NVARCHAR(10)   = ''   

         , @n_PendingMoveIn      INT            = 0                                                 
         , @c_UserName           NVARCHAR(128)  = dbo.Fnc_GetUserName()  
         , @c_PutACode           NVARCHAR(10)   = ''
                                              
         , @c_ASNPATask_OP5      NVARCHAR(1000) = '' 
         , @c_LPNAttribPAGrp     NVARCHAR(1000) = '' 
         , @c_PAGrpSortBy        NVARCHAR(1000) = '' 
 
         , @c_SQL                NVARCHAR(MAX)  = ''
         , @c_SQLParms           NVARCHAR(MAX) = ''
        
         , @CUR_PAGRP            CURSOR
         , @CUR_PAID             CURSOR
  
   SET @b_Success  = 1
   SET @n_Err      = 0
   SET @c_Errmsg   = ''
   SET @c_UserName = dbo.Fnc_GetUserName()

   --WHILE @@TRANCOUNT > 0
   --BEGIN
   --   COMMIT TRAN
   --END

   BEGIN TRAN

   IF OBJECT_ID('tempdb..#PARECEIPTDETAIL_WIP') IS NOT NULL  
   BEGIN
      DROP TABLE #PARECEIPTDETAIL_WIP
   END
 
   CREATE TABLE #PARECEIPTDETAIL_WIP
   (  Receiptkey        NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  ReceiptLineNumber NVARCHAR(5)    NOT NULL DEFAULT('')
   ,  Storerkey         NVARCHAR(15)   NOT NULL DEFAULT('')
   ,  Sku               NVARCHAR(20)   NOT NULL DEFAULT('')
   ,  Packkey           NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  UOM               NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  QtyReceived       INT            NOT NULL DEFAULT(0)
   ,  ToLoc             NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  ToID              NVARCHAR(18)   NOT NULL DEFAULT('')
   ,  Lottable01        NVARCHAR(18)   NOT NULL DEFAULT('')
   ,  Lottable02        NVARCHAR(18)   NOT NULL DEFAULT('')
   ,  Lottable03        NVARCHAR(18)   NOT NULL DEFAULT('')
   ,  Lottable04        DATETIME       NULL
   ,  Lottable05        DATETIME       NULL
   ,  Lottable06        NVARCHAR(30)   NOT NULL DEFAULT('')
   ,  Lottable07        NVARCHAR(30)   NOT NULL DEFAULT('')
   ,  Lottable08        NVARCHAR(30)   NOT NULL DEFAULT('')
   ,  Lottable09        NVARCHAR(30)   NOT NULL DEFAULT('')
   ,  Lottable10        NVARCHAR(30)   NOT NULL DEFAULT('')
   ,  Lottable11        NVARCHAR(30)   NOT NULL DEFAULT('')
   ,  Lottable12        NVARCHAR(30)   NOT NULL DEFAULT('')
   ,  Lottable13        DATETIME NULL
   ,  Lottable14        DATETIME NULL
   ,  Lottable15        DATETIME NULL
   ,  LPNQtyClass       NVARCHAR(20)   NOT NULL DEFAULT('')  
   ,  GrpNo             INT            NOT NULL DEFAULT(0)
   ,  GrpSortBy         INT            NOT NULL DEFAULT(0)
   )

   SELECT @c_Facility = r.Facility
         ,@c_Storerkey= r.StorerKey
         ,@c_ASNStatus= r.ASNStatus
   FROM Receipt r (NOLOCK)
   WHERE r.ReceiptKey = @c_ReceiptKey
   
   IF @c_ASNStatus < '9' -- check Receipt.ASNStatus = '9' then able to release PA task. 
   BEGIN
      SET @n_Continue = 3
      SET @n_Err = 60110
      SET @c_Errmsg = 'NSQL'+CONVERT(CHAR(5),@n_err)+': ASN has not closed yet. (mspPARL02)'
      GOTO QUIT_SP
   END

   SELECT  @c_PutACode = gr.Option1
         , @c_ASNPATask_OP5 = gr.Option5
   FROM dbo.fnc_GetRight2(@c_Facility, @c_Storerkey, '', 'ASNReleasePATask_SP') gr

   SET @c_TaskType = 'PAF'
   SELECT @c_TaskType = dbo.fnc_GetParamValueFromString('@c_TaskType', @c_ASNPATask_OP5, @c_TaskType)

   SET @c_LPNAttribPAGrp = 'RECEIPTDETAIL.ToID'
   SELECT @c_LPNAttribPAGrp = dbo.fnc_GetParamValueFromString('@c_LPNAttribPAGrp', @c_ASNPATask_OP5, @c_LPNAttribPAGrp)

   SET @c_PAGrpSortBy = 'RECEIPTDETAIL.ReceiptLineNumber'
   SELECT @c_PAGrpSortBy = dbo.fnc_GetParamValueFromString('@c_PAGrpSortBy', @c_ASNPATask_OP5, @c_PAGrpSortBy)

   INSERT INTO #PARECEIPTDETAIL_WIP  
                       (Receiptkey, ReceiptLineNumber, Storerkey, Sku, Packkey, UOM
                       ,QtyReceived, ToLoc, ToID
                       ,Lottable01, Lottable02, Lottable03, Lottable04, Lottable05
                       ,Lottable06, Lottable07, Lottable08, Lottable09, Lottable10
                       ,Lottable11, Lottable12, Lottable13, Lottable14, Lottable15
                       ,LPNQtyClass, GrpSortBy
                       )
   SELECT  rd.Receiptkey, rd.ReceiptLineNumber, rd.Storerkey, rd.Sku, rd.Packkey, rd.UOM
         , rd.QtyReceived, rd.ToLoc, rd.ToID
         , Lottable01, Lottable02, Lottable03, Lottable04, Lottable05
         , Lottable06, Lottable07, Lottable08, Lottable09, Lottable10
         , Lottable11, Lottable12, Lottable13, Lottable14, Lottable15
         ,'',''
   FROM dbo.RECEIPTDETAIL rd (NOLOCK)
   JOIN LOTxLOCxID lli (NOLOCK) ON  lli.StorerKey = rd.StorerKey
                                AND lli.Loc = rd.ToLoc
                                AND lli.ID  = rd.ToID
   LEFT OUTER JOIN TaskDetail td (NOLOCK) ON  td.FromLoc = rd.ToLoc
                                          AND td.FromID  = rd.ToID
                                          AND td.Storerkey = rd.Storerkey
                                          AND td.TaskType  = @c_TaskType 
                                          AND td.Sourcekey = rd.ReceiptKey
                                          AND td.[Status] NOT IN ('9','X')
   WHERE rd.ReceiptKey = @c_ReceiptKey
   AND   rd.ToID > ''
   AND   rd.FinalizeFlag = 'Y' -- able to release tasks after finalization
   AND   rd.QtyReceived > 0
   AND   lli.Qty > 0
   AND   td.TaskDetailKey IS NULL

   SET @n_RowCount = @@ROWCOUNT

   IF @n_RowCount = 0
   BEGIN
      SET @n_Continue = 4
   END

   IF @n_Continue = 1
   BEGIN
      UPDATE rd
      SET LPNQtyClass = p.LPNQtyClass
      FROM #PARECEIPTDETAIL_WIP rd
      CROSS APPLY (  SELECT RECEIPTDETAIL.ToLoc
                           ,RECEIPTDETAIL.ToID
                           ,LPNQtyClass = CASE WHEN SUM(RECEIPTDETAIL.QtyReceived) = PACK.Pallet
                                               THEN 'FULLPALLET'
                                               ELSE 'PARTIALPALLET'
                                               END
                     FROM #PARECEIPTDETAIL_WIP As RECEIPTDETAIL
                     JOIN SKU (NOLOCK) ON  SKU.Storerkey = RECEIPTDETAIL.Storerkey
                                                 AND SKU.Sku = RECEIPTDETAIL.Sku
                     JOIN PACK (NOLOCK) ON  PACK.Packkey = SKU.PackKey
                     GROUP BY RECEIPTDETAIL.ToLoc, RECEIPTDETAIL.ToID, PACK.Pallet
                  ) p
      WHERE rd.ToLoc = p.ToLoc 
      AND   rd.ToID = p.ToID
            
      --@c_LPNAttribPAGrp = 'CASE WHEN ''PARTIALPALLET'' THEN RECEIPTDETAIL.ToID ELSE '' END 
      --                    ,RECEIPTDETAIL.Sku, RECEIPTDETAIL.Lottable02'
      
      IF @c_LPNAttribPAGrp > ''
      BEGIN
         SET @c_LPNAttribPAGrp = REPLACE(@c_LPNAttribPAGrp,'''FULLPALLET''','RECEIPTDETAIL.LPNQtyClass=''FULLPALLET''')
         SET @c_LPNAttribPAGrp = REPLACE(@c_LPNAttribPAGrp,'''PARTIALPALLET''','RECEIPTDETAIL.LPNQtyClass=''PARTIALPALLET''')
      END

      -- SET @c_PAGrpSortBy = 'CASE WHEN ''PARTIALPALLET'' THEN 1 ELSE 0 END'
      IF @c_PAGrpSortBy > ''
      BEGIN
         SET @c_PAGrpSortBy = REPLACE(@c_PAGrpSortBy,'''FULLPALLET''','RECEIPTDETAIL.LPNQtyClass=''FULLPALLET''')
         SET @c_PAGrpSortBy = REPLACE(@c_PAGrpSortBy,'''PARTIALPALLET''','RECEIPTDETAIL.LPNQtyClass=''PARTIALPALLET''')
      END

      SET @c_SQL = N'UPDATE rd'
                 + ' SET rd.GrpNo = pag.GrpNo'
                 + ' FROM #PARECEIPTDETAIL_WIP as rd'
                 + ' CROSS APPLY (  SELECT RECEIPTDETAIL.ReceiptLineNumber'
                 +                     ' , GrpNo = DENSE_RANK() OVER (ORDER BY'
                 + ' ' + @c_LPNAttribPAGrp + ')' 
                 +                ' FROM #PARECEIPTDETAIL_WIP as RECEIPTDETAIL'
                 +             ' ) pag'
                 + ' WHERE rd.ReceiptLineNumber = pag.ReceiptLineNumber'                   
      EXEC sp_ExecuteSQL @c_SQL  

      SET @c_SQL = N'UPDATE rd
                     SET rd.GrpSortBy = ps.GrpSortBy
                     FROM #PARECEIPTDETAIL_WIP as rd
                     CROSS APPLY (  SELECT RECEIPTDETAIL.ReceiptLineNumber
                                         , GrpSortBy = DENSE_RANK() OVER (ORDER BY '
                 +  @c_PAGrpSortBy + ')' 
                 +                ' FROM #PARECEIPTDETAIL_WIP as RECEIPTDETAIL
                                 ) ps
                     WHERE rd.ReceiptLineNumber = ps.ReceiptLineNumber'                   
      EXEC sp_ExecuteSQL @c_SQL  

      IF @b_Debug = 1
      BEGIN
         PRINT '@c_PAGrpSortBy: ' + @c_PAGrpSortBy
         SELECT --TOP 1 WITH TIES
                rd.GrpNo
               ,rd.GrpSortBy
               ,rd.LPNQtyClass
               ,rd.ReceiptLineNumber
               ,rd.Sku
               ,rd.Packkey
               ,rd.UOM
               ,rd.ToLoc
               ,rd.ToID
               ,rd.Lottable01
               ,rd.Lottable02
               ,rd.Lottable03
               ,rd.Lottable04
               ,rd.Lottable05
               ,rd.Lottable06
               ,rd.Lottable07
               ,rd.Lottable08
               ,rd.Lottable09
               ,rd.Lottable10
               ,rd.Lottable11
               ,rd.Lottable12
               ,rd.Lottable13
               ,rd.Lottable14
               ,rd.Lottable15
         FROM #PARECEIPTDETAIL_WIP rd (NOLOCK)
         ORDER BY ROW_NUMBER() OVER (PARTITION BY rd.GrpNo ORDER BY rd.GrpSortBy)
      END

      SET @CUR_PAGRP = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR 
      SELECT TOP 1 WITH TIES
             rd.GrpNo
            ,rd.ReceiptLineNumber
            ,rd.Sku
            ,rd.Packkey
            ,rd.UOM
            ,rd.ToLoc
            ,rd.ToID
            ,rd.Lottable01
            ,rd.Lottable02
            ,rd.Lottable03
            ,rd.Lottable04
            ,rd.Lottable05
            ,rd.Lottable06
            ,rd.Lottable07
            ,rd.Lottable08
            ,rd.Lottable09
            ,rd.Lottable10
            ,rd.Lottable11
            ,rd.Lottable12
            ,rd.Lottable13
            ,rd.Lottable14
            ,rd.Lottable15
      FROM #PARECEIPTDETAIL_WIP rd (NOLOCK)
      ORDER BY ROW_NUMBER() OVER (PARTITION BY rd.GrpNo ORDER BY rd.GrpSortBy)

      OPEN @CUR_PAGRP 
 
      FETCH NEXT FROM @CUR_PAGRP INTO @n_GrpNo, @c_ReceiptLineNumber, @c_Sku, @c_Packkey, @c_UOM
                                    , @c_FromLoc, @c_FromID
                                    , @c_Lottable01, @c_Lottable02, @c_Lottable03, @dt_Lottable04, @dt_Lottable05
                                    , @c_Lottable06, @c_Lottable07, @c_Lottable08, @c_Lottable09, @c_Lottable10
                                    , @c_Lottable11, @c_Lottable12, @dt_Lottable13, @dt_Lottable14, @dt_Lottable15

      WHILE @@FETCH_STATUS <> -1 
      BEGIN
         SET @n_Continue = 1
         SET @n_NoOfLPN  = 0
         SET @n_PutawayCapacity = 0
         SET @c_Lot      = ''
         --SET @c_FromID   = ''
         SET @c_ToLoc    = ''
         SET @c_FinalLoc = ''
         SET @c_Areakey  = ''
         SET @dt_Lottable04 = CONVERT(DATE, @dt_Lottable04)
         SET @dt_Lottable05 = CONVERT(DATE, @dt_Lottable05)
         SET @dt_Lottable13 = CONVERT(DATE, @dt_Lottable13)
         SET @dt_Lottable14 = CONVERT(DATE, @dt_Lottable14)
         SET @dt_Lottable15 = CONVERT(DATE, @dt_Lottable15)
 
         SELECT @n_NoOfLPN = COUNT(DISTINCT rd.ToID)
         FROM #PARECEIPTDETAIL_WIP rd (NOLOCK)
         WHERE rd.GrpNo = @n_GrpNo 
         GROUP BY rd.GrpNo

         SELECT @n_QtyReceived = SUM(rd.QtyReceived)
         FROM #PARECEIPTDETAIL_WIP rd (NOLOCK)
         WHERE rd.ToID = @c_FromID 
         GROUP BY rd.ToID
         
         IF @c_LPNAttribPAGrp NOT like '%.Lottable01%'
         BEGIN
            SET @c_Lottable01 = ''
         END

         IF @c_LPNAttribPAGrp NOT like '%.Lottable02%'
         BEGIN
            SET @c_Lottable02 = ''
         END

         IF @c_LPNAttribPAGrp NOT like '%.Lottable03%'
         BEGIN
            SET @c_Lottable03 = ''
         END

         IF @c_LPNAttribPAGrp NOT like '%.Lottable04%'
         BEGIN
            SET @dt_Lottable04 = NULL
         END

         IF @c_LPNAttribPAGrp NOT like '%.Lottable05%'
         BEGIN
            SET @dt_Lottable05 = NULL
         END

         IF @c_LPNAttribPAGrp NOT like '%.Lottable06%'
         BEGIN
            SET @c_Lottable06 = ''
         END

         IF @c_LPNAttribPAGrp NOT like '%.Lottable07%'
         BEGIN
            SET @c_Lottable07 = ''
         END

         IF @c_LPNAttribPAGrp NOT like '%.Lottable08%'
         BEGIN
            SET @c_Lottable08 = ''
         END

         IF @c_LPNAttribPAGrp NOT like '%.Lottable09%'
         BEGIN
            SET @c_Lottable09 = ''
         END

         IF @c_LPNAttribPAGrp NOT like '%.Lottable10%'
         BEGIN
            SET @c_Lottable10 = ''
         END

         IF @c_LPNAttribPAGrp NOT like '%.Lottable11%'
         BEGIN
            SET @c_Lottable11 = ''
         END

         IF @c_LPNAttribPAGrp NOT like '%.Lottable12%'
         BEGIN
            SET @c_Lottable12 = ''
         END

         IF @c_LPNAttribPAGrp NOT like '%.Lottable13%'
         BEGIN
            SET @dt_Lottable13 = NULL
         END

         IF @c_LPNAttribPAGrp NOT like '%.Lottable14%'
         BEGIN
            SET @dt_Lottable14 = NULL
         END

         IF @c_LPNAttribPAGrp NOT like '%.Lottable15%'
         BEGIN
            SET @dt_Lottable15 = NULL
         END

         SET @n_LPNLeftToFulfill = @n_NoOfLPN
         SET @n_AvailablePASlot  = 0

         SAVE TRANSACTION LPN_PA         
         WHILE @n_LPNLeftToFulfill > 0 AND @n_Continue = 1
         BEGIN
            IF @b_Debug = 1
            BEGIN
               PRINT '@c_FromID: ' + @c_FromID
                 + ', @n_LPNLeftToFulfill: ' + CAST( @n_LPNLeftToFulfill AS NVARCHAR)
            END

            SET @c_SQL = ' ' + @c_PutACode + ' '
                       + N'@c_Storerkey = @c_Storerkey'
                       + ',@c_Lot = @c_Lot' 
                       + ',@c_Sku = @c_Sku' 
                       + ',@c_ID  = @c_FromID'
                       + ',@c_FromLoc = @c_FromLoc'
                       + ',@n_Qty = @n_QtyReceived' 
                       + ',@c_UOM = @c_UOM'
                       + ',@c_Packkey = @c_Packkey' 
                       + ',@n_PutawayCapacity = @n_PutawayCapacity'
                       + ',@c_Final_ToLoc = @c_ToLoc OUTPUT'
                       + ',@n_AvailablePASlot = @n_AvailablePASlot OUTPUT' 
                       + ',@n_LPNLeftToFulfill = @n_LPNLeftToFulfill' 
                       + ',@c_ReceiptKey = @c_ReceiptKey'
                       + ',@c_ReceiptLineNumber = @c_ReceiptLineNumber' 
                       + ',@c_Lottable01 = @c_Lottable01' 
                       + ',@c_Lottable02 = @c_Lottable02' 
                       + ',@c_Lottable03 = @c_Lottable03' 
                       + ',@dt_Lottable04= @dt_Lottable04' 
                       + ',@dt_Lottable05= @dt_Lottable05'
                       + ',@c_Lottable06 = @c_Lottable06' 
                       + ',@c_Lottable07 = @c_Lottable07' 
                       + ',@c_Lottable08 = @c_Lottable08' 
                       + ',@c_Lottable09 = @c_Lottable09' 
                       + ',@c_Lottable10 = @c_Lottable10'
                       + ',@c_Lottable11 = @c_Lottable11' 
                       + ',@c_Lottable12 = @c_Lottable12' 
                       + ',@dt_Lottable13= @dt_Lottable13' 
                       + ',@dt_Lottable14= @dt_Lottable14' 
                       + ',@dt_Lottable15= @dt_Lottable15'  
                       + ',@b_Debug= @b_Debug'                          

            SET @c_SQLParms = N'@c_Storerkey NVARCHAR(15)'
                            + ',@c_Lot NVARCHAR(10)' 
                            + ',@c_Sku NVARCHAR(20)' 
                            + ',@c_FromID  NVARCHAR(18)'
                            + ',@c_FromLoc NVARCHAR(10)'
                            + ',@n_QtyReceived INT' 
                            + ',@c_UOM NVARCHAR(10)'
                            + ',@c_Packkey NVARCHAR(10)' 
                            + ',@n_PutawayCapacity  INT'
                            + ',@c_ToLoc   NVARCHAR(10) OUTPUT'
                            + ',@n_AvailablePASlot  INT OUTPUT'
                            + ',@n_LPNLeftToFulfill INT' 
                            + ',@c_ReceiptKey NVARCHAR(10)'
                            + ',@c_ReceiptLineNumber NVARCHAR(5)' 
                            + ',@c_Lottable01  NVARCHAR(18)'
                            + ',@c_Lottable02  NVARCHAR(18)'
                            + ',@c_Lottable03  NVARCHAR(18)'
                            + ',@dt_Lottable04 DATETIME' 
                            + ',@dt_Lottable05 DATETIME'
                            + ',@c_Lottable06  NVARCHAR(30)'
                            + ',@c_Lottable07  NVARCHAR(30)'
                            + ',@c_Lottable08  NVARCHAR(30)'
                            + ',@c_Lottable09  NVARCHAR(30)'
                            + ',@c_Lottable10  NVARCHAR(30)'
                            + ',@c_Lottable11  NVARCHAR(30)'
                            + ',@c_Lottable12  NVARCHAR(30)'
                            + ',@dt_Lottable13 DATETIME' 
                            + ',@dt_Lottable14 DATETIME' 
                            + ',@dt_Lottable15 DATETIME'  
                            + ',@b_Debug  INT'     
 
            EXEC sp_ExecuteSQL @c_SQL
                              ,@c_SQLParms
                              ,@c_Storerkey
                              ,@c_Lot 
                              ,@c_Sku
                              ,@c_FromID
                              ,@c_FromLoc 
                              ,@n_QtyReceived
                              ,@c_UOM
                              ,@c_Packkey 
                              ,@n_PutawayCapacity 
                              ,@c_ToLoc            OUTPUT 
                              ,@n_AvailablePASlot  OUTPUT
                              ,@n_LPNLeftToFulfill  
                              ,@c_ReceiptKey
                              ,@c_ReceiptLineNumber
                              ,@c_Lottable01 
                              ,@c_Lottable02 
                              ,@c_Lottable03 
                              ,@dt_Lottable04
                              ,@dt_Lottable05
                              ,@c_Lottable06 
                              ,@c_Lottable07 
                              ,@c_Lottable08 
                              ,@c_Lottable09 
                              ,@c_Lottable10 
                              ,@c_Lottable11 
                              ,@c_Lottable12 
                              ,@dt_Lottable13
                              ,@dt_Lottable14
                              ,@dt_Lottable15
                              ,@b_Debug
 
            IF @c_ToLoc = '' OR @n_AvailablePASlot = 0
            BEGIN
               SET @n_AvailablePASlot = @n_LPNLeftToFulfill
            END

            IF @b_Debug = 1
            BEGIN
               PRINT 'mspPARL02: '
               + '@c_ToLoc: ' + @c_ToLoc
               +   ', @n_AvailablePASlot: ' + CAST (@n_AvailablePASlot AS NVARCHAR)
            END

            IF @n_Continue = 1
            BEGIN
               SET @b_ManualBreak = 1                                               --2026-03-27
               SET @c_ReceiptLineNumber = ''
               SET @CUR_PAID = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR 
               SELECT   rd.ReceiptKey
                     ,  rd.StorerKey
                     ,  rd.Sku
                     ,  rd.ToLoc
                     ,  rd.ToID
                     ,  QtyReceived = SUM(rd.QtyReceived)
               FROM #PARECEIPTDETAIL_WIP rd (NOLOCK)
               WHERE rd.GrpNo = @n_GrpNo
               AND NOT EXISTS (SELECT 1 FROM TaskDetail td (NOLOCK) 
                               WHERE td.FromID = rd.ToID
                               AND td.Tasktype = @c_TaskType                        --2026-03-27
                               AND td.Sourcekey= rd.Receiptkey                      --2026-03-27
                               AND td.[Status] <> 'X'                               --2026-03-24
                              )
               GROUP BY rd.ReceiptKey
                     ,  rd.StorerKey
                     ,  rd.Sku
                     ,  rd.ToLoc
                     ,  rd.ToID
                     ,  rd.GrpSortBy
               ORDER BY rd.GrpSortBy
                      , MIN(rd.ReceiptLineNumber)
                     

               OPEN @CUR_PAID 
               FETCH NEXT FROM @CUR_PAID INTO @c_ReceiptKey 
                                           ,  @c_Storerkey, @c_Sku 
                                           ,  @c_FromLoc, @c_FromID, @n_QtyReceived

               WHILE @@FETCH_STATUS <> -1 AND @n_AvailablePASlot > 0 AND @n_Continue = 1
               BEGIN
                  SET @b_ManualBreak = 0                                            --2026-03-27
                  SET @n_PendingMoveIn = 0

                  IF @c_ToLoc > '' 
                  BEGIN
                     SET @n_PendingMoveIn = @n_QtyReceived
                  END

                  EXECUTE nspg_GetKey
                     @KeyName     = 'TaskDetailKey'
                  ,  @fieldlength = 10
                  ,  @keystring   = @c_TaskDetailKey OUTPUT
                  ,  @b_Success   = @b_success       OUTPUT
                  ,  @n_err       = @n_err           OUTPUT
                  ,  @c_errmsg    = @c_errmsg        OUTPUT

                  IF @b_success = 0
                  BEGIN
                     SET @n_Continue = 3
                  END

                  IF @n_Continue = 1
                  BEGIN
                     SELECT TOP 1 @c_Areakey = a.AreaKey
                     FROM dbo.LOC l (NOLOCK)
                     JOIN AreaDetail a (NOLOCK) ON a.PutawayZone = l.PutawayZone
                     WHERE Loc = @c_FromLoc      
                     ORDER BY a.AreaKey

                     SET @c_Lot = ''
                     SELECT @c_Lot = MIN(lli.Lot) 
                     FROM LOTxLOCxID lli (NOLOCK)
                     WHERE lli.Storerkey = @c_Storerkey
                     AND   lli.Loc = @c_FromLoc
                     AND   lli.ID  = @c_FromID
                     GROUP BY lli.Storerkey
                           ,  lli.Loc
                           ,  lli.ID
                     HAVING COUNT(DISTINCT lli.Lot) = 1

                     IF @b_Debug = 1
                     BEGIN
                        PRINT 'Inserting TASKDETAIL: 
                        @c_TaskDetailKey='+@c_TaskDetailKey+',
                        @c_TaskType='+@c_TaskType+',
                        @c_Lot='+@c_Lot+',
                        @c_UOM='+@c_UOM+',
                        @c_FromLoc='+@c_FromLoc+',
                        @c_FromID='+@c_FromID+',
                        @c_ToLoc='+@c_ToLoc+',
                        @c_FinalLoc='+@c_FinalLoc+',
                        @c_FromLogicalLoc='+@c_FromLogicalLoc+',
                        @c_ToLogicalLoc='+@c_ToLogicalLoc+',
                        @c_Areakey='+@c_Areakey+',
                        @c_PickMethod='+@c_PickMethod+',
                        @c_SourceType='+@c_SourceType+',
                        @c_ReceiptKey='+@c_ReceiptKey+', 
                        @c_Storerkey='+@c_Storerkey+', 
                        @c_Sku='+@c_Sku+',
                        @c_FromLoc='+@c_FromLoc+', 
                        @c_FromID='+@c_FromID+', 
                        @n_QtyReceived='+CAST(@n_QtyReceived AS VARCHAR(10))
                        +', @n_PendingMoveIn:' + CAST(@n_PendingMoveIn AS VARCHAR(10))                        
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
                              ,  @c_FromID
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
                              ,  @n_PendingMoveIn                                                           
                            )

                     SET @n_Err = @@ERROR
                     IF @n_Err <> 0
                     BEGIN 
                        SET @n_Continue = 3
                        SET @c_ErrMsg   =  ERROR_MESSAGE()
                     END

                     IF @n_Continue = 1
                     BEGIN
                        SET @n_NoOfTasks = @n_NoOfTasks + 1
                        SET @n_AvailablePASlot = @n_AvailablePASlot - 1
                        SET @n_LPNLeftToFulfill = @n_LPNLeftToFulfill - 1
                     END
                  END

                  FETCH NEXT FROM @CUR_PAID INTO @c_ReceiptKey 
                                              ,  @c_Storerkey, @c_Sku
                                              ,  @c_FromLoc, @c_FromID, @n_QtyReceived
               END
               CLOSE @CUR_PAID
               DEALLOCATE @CUR_PAID

               IF @b_ManualBreak = 1                                                --2027-03-27
               BEGIN
                  SET @n_LPNLeftToFulfill = 0
               END
            END
         END

         IF @n_Continue = 3
         BEGIN
            ROLLBACK TRANSACTION LPN_PA
         END

         FETCH NEXT FROM @CUR_PAGRP INTO @n_GrpNo, @c_ReceiptLineNumber, @c_Sku, @c_Packkey, @c_UOM
                        , @c_FromLoc, @c_FromID
                        , @c_Lottable01, @c_Lottable02, @c_Lottable03, @dt_Lottable04, @dt_Lottable05
                        , @c_Lottable06, @c_Lottable07, @c_Lottable08, @c_Lottable09, @c_Lottable10
                        , @c_Lottable11, @c_Lottable12, @dt_Lottable13, @dt_Lottable14, @dt_Lottable15
      END
      CLOSE @CUR_PAGRP
      DEALLOCATE @CUR_PAGRP
   END
   SET @n_Continue = 1
   QUIT_SP:

   IF OBJECT_ID('tempdb..#PARECEIPTDETAIL_WIP') IS NOT NULL  
   BEGIN
      DROP TABLE #PARECEIPTDETAIL_WIP
   END
 
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
      execute nsp_logerror @n_err, @c_errmsg, 'mspPARL02'
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