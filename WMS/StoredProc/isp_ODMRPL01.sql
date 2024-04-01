SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Stored Procedure: isp_ODMRPL01                                          */
/* Creation Date:  27-AUG-2017                                             */
/* Copyright: LFL                                                          */
/* Written by:Wan                                                          */
/*                                                                         */
/* Purpose: This Stored procedure include Replenishment logic and          */
/*        : Task creation as well as Replenishment record generation       */
/*                                                                         */
/* Called By: RDT and SCE Generate Report Stored Procedure                 */
/*                                                                         */
/* PVCS Version: 1.0                                                       */
/*                                                                         */
/* Version: MWMS V2                                                        */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author  Ver   Purposes                                     */
/* 31-Aug-2019  SHONG   1.0   Create UWP-14725                             */
/***************************************************************************/

CREATE OR ALTER PROC [dbo].[isp_ODMRPL01]
    @c_Facility   NVARCHAR(5)    = '',
    @c_Storerkey  NVARCHAR(15)   = '',
    @c_SKU        NVARCHAR(20)   = '',
    @c_LOC        NVARCHAR(10)   = '',
    @c_ReplenType NVARCHAR(50)   = 'T', -- T=TaskManager/R-Replenishment
    @c_ReplenishmentGroup NVARCHAR(10)   = '', 
    @b_Success    INT OUTPUT,
    @n_Err        INT OUTPUT,
    @c_ErrMsg     NVARCHAR(255) OUTPUT,
    @b_Debug      INT = 0

AS
BEGIN
    SET NOCOUNT ON
    SET ANSI_NULLS OFF
    SET QUOTED_IDENTIFIER OFF
    SET CONCAT_NULL_YIELDS_NULL OFF

    DECLARE @n_StartTCnt            INT            = @@TRANCOUNT
         , @n_Continue              INT            = 1

         , @c_Wavekey               NVARCHAR(10)   = ''
         
         
         , @c_ReplenishmentKey      NVARCHAR(10)   = ''
         
         , @c_Priority              NVARCHAR(5)    = ''

         , @n_InvCnt                INT
         , @c_CurrentStorer         NVARCHAR(15)   = ''
         , @c_CurrentSKU            NVARCHAR(20)   = ''
         , @c_CurrentLoc            NVARCHAR(10)   = ''
         , @c_CurrentPriority       NVARCHAR(5)    = ''
         , @n_Currentfullcase       INT            = 0
         , @n_CurrentSeverity       INT            = 9999999
         , @c_FromLOC               NVARCHAR(10)   = ''
         , @c_Fromlot               NVARCHAR(10)   = ''
         , @c_FromID                NVARCHAR(18)   = ''
         , @c_ToID                  NVARCHAR(18)   = ''
         , @n_FromQty               INT            = 0
         , @n_QtyPreAllocated       INT            = 0
         , @n_QtyAllocated          INT            = 0
         , @n_QtyPicked             INT            = 0
         , @n_RemainingQty          INT            = 0

         , @c_NoMixLottable02       NVARCHAR(10)   = '0'
         , @c_ReplLottable02        NVARCHAR(18)   = ''

         , @c_ReplValidationRules   NVARCHAR(10)   = ''

         , @c_Packkey               NVARCHAR(10)   = ''
         , @c_UOM                   NVARCHAR(10)   = ''
         , @c_ToLocationType        NVARCHAR(10)   = ''
         , @n_CaseCnt               FLOAT          = 0.00
         , @n_Pallet                FLOAT          = 0.00

         , @n_FilterQty             INT            = 0
         , @c_ReplFullPallet        NVARCHAR(10)   = 'N'
         , @c_ReplAllPalletQty      NVARCHAR(10)   = 'N'
         , @c_CaseToPick            NVARCHAR(10)   = 'N'
         , @c_ReplOverFlow          NVARCHAR(10)   = 'Y'

         , @n_RowID                 INT            = 0
         , @CUR_REPEN               CURSOR

         , @n_MaxCapacity           INT            = 0
         , @n_QtyReplen             INT            = 0
         , @c_NextLOC               NVARCHAR(10)   = ''
         , @n_TotReplenQty          INT            = 0
         , @c_LottableName          NVARCHAR(30)   = ''  
         , @c_LottableValue         NVARCHAR(30)   = ''  
         , @c_SQL                   NVARCHAR(MAX)  = ''
         , @n_CursorRows            INT            = 0 

         , @c_TaskDetailKey         NVARCHAR(10)   = '' 
         , @c_FromLogicalLoc        NVARCHAR(10)   = '' 
         , @c_FromAreaKey           NVARCHAR(10)   = ''  
         , @c_ToLogicalLoc          NVARCHAR(10)   = '' 
         , @c_ToAreaKey             NVARCHAR(10)   = '' 

    WHILE @@TRANCOUNT > 0
    BEGIN
        COMMIT TRAN
    END

    BEGIN TRAN

 
    IF ISNULL(RTRIM(@c_LOC), '') = ''
    BEGIN
      IF @b_debug = 1
         PRINT '<<< Location Paramater Blank! '
          
       GOTO QUIT_SP
    END 

   SELECT TOP 1
      @c_Facility  = LOC.Facility
   FROM LOC WITH (NOLOCK)
   WHERE LOC.LOC = @c_LOC

 
    IF @n_continue = 1
    BEGIN
        SET @c_ReplenishmentKey = ''
        SET @c_ReplFullPallet = 'Y'
        SET @c_ReplAllPalletQty = 'Y'
        SET @c_CaseToPick = 'N'

        -- SELECT @c_ReplFullPallet  = ISNULL(MAX(CASE WHEN CL.Code ='ReplFullPallet'   THEN 'Y' ELSE 'N' END),'N')
        --     , @c_ReplAllPalletQty= ISNULL(MAX(CASE WHEN CL.Code ='ReplAllPalletQty' THEN 'Y' ELSE 'N' END),'N')
        --     , @c_CaseToPick      = ISNULL(MAX(CASE WHEN CL.Code ='REPLCASETOPICK' THEN 'Y' ELSE 'N' END),'N')
        -- FROM CODELKUP CL WITH (NOLOCK)
        -- WHERE CL.ListName = 'REPORTCFG'
        --     AND CL.Long = 'r_Replenishment_fpa_move01'
        --     AND CL.Storerkey = @c_Storerkey
        --     AND CL.Short = 'Y'

        IF @c_ReplAllPalletQty = 'Y'
        BEGIN
            SET @c_ReplFullPallet = 'N'
        END

        IF OBJECT_ID('tempdb..#Replenishment','u') IS NOT NULL
        BEGIN
            DROP TABLE #Replenishment;
        END

        CREATE TABLE #Replenishment
        (
            RowID INT IDENTITY(1,1) PRIMARY KEY,
            StorerKey NVARCHAR(15) NOT NULL DEFAULT(''),
            SKU NVARCHAR(20) NOT NULL DEFAULT(''),
            FromLOC NVARCHAR(10) NOT NULL DEFAULT(''),
            ToLOC NVARCHAR(10) NOT NULL DEFAULT(''),
            Lot NVARCHAR(10) NOT NULL DEFAULT(''),
            ID NVARCHAR(18) NOT NULL DEFAULT(''),
            LocationType NVARCHAR(10) NOT NULL DEFAULT(''),
            Qty INT NOT NULL DEFAULT(0),
            QtyMoved INT NOT NULL DEFAULT(0),
            QtyInPickLOC INT NOT NULL DEFAULT(0),
            [Priority] NVARCHAR(10) NOT NULL DEFAULT(''),
            UOM NVARCHAR(10) NOT NULL DEFAULT(''),
            Packkey NVARCHAR(10) NOT NULL DEFAULT(''),
            ReplLottable02 NVARCHAR(18) NOT NULL DEFAULT('')
        )

        IF OBJECT_ID('tempdb..#TempSKUxLOC','u') IS NOT NULL
        BEGIN
            DROP TABLE #TempSKUxLOC;
        END

        CREATE TABLE #TempSKUxLOC
        (
            RowID INT IDENTITY(1,1) PRIMARY KEY,
            StorerKey NVARCHAR(15) NOT NULL DEFAULT(''),
            SKU NVARCHAR(20) NOT NULL DEFAULT(''),
            LOC NVARCHAR(10) NOT NULL DEFAULT(''),
            ReplenishmentPriority NVARCHAR(5) NOT NULL DEFAULT(''),
            ReplenishmentSeverity INT NOT NULL DEFAULT(0),
            ReplenishmentCasecnt INT NOT NULL DEFAULT(0),
            LocationType NVARCHAR(10) NOT NULL DEFAULT(''),
            NoMixLottable02 NVARCHAR(1) NOT NULL DEFAULT(''),
            Packkey NVARCHAR(10) NOT NULL DEFAULT(''),
            LOT NVARCHAR(10) NOT NULL DEFAULT(''),
            Selected BIT NOT NULL DEFAULT(0),
            QtyReplen INT NOT NULL DEFAULT(0)
        )

        IF OBJECT_ID('tempdb..#SkipSku','u') IS NOT NULL
        BEGIN
            DROP TABLE #SkipSku;
        END

        CREATE TABLE #SkipSku
        (
            SKU NVARCHAR(20)
        )

        -- Do not execute it Replenishment Task not done yet       
        IF @c_ReplenType = 'R'
        BEGIN        
           IF EXISTS(SELECT 1
                     FROM Replenishment RP WITH (NOLOCK)
                     WHERE (RP.Storerkey = @c_Storerkey 
                     AND RP.Sku = @c_SKU 
                     AND RP.ToLoc = @c_LOC)
                     AND (RP.Confirmed = 'N') ) 
           BEGIN
               PRINT '>>>>>> Replenishment Exists, Do nothing'
               GOTO QUIT_SP
           END
        END 

        IF @c_ReplenType = 'T'
        BEGIN
           IF EXISTS(SELECT 1
                     FROM TaskDetail TD WITH (NOLOCK)
                     WHERE (TD.Storerkey = @c_Storerkey 
                     AND TD.Sku = @c_SKU 
                     AND TD.ToLoc = @c_LOC)
                     AND (TD.Status IN ('Q', '0','1', '3'))
                     AND TD.TaskType = 'VNAOUT')
           BEGIN
               PRINT '>>>>>> Replenishment Task Exists, Do nothing'
               GOTO QUIT_SP
           END

        END 

        IF NOT EXISTS (SELECT 1
                       FROM SKUxLOC SL (NOLOCK) 
                       JOIN LOTxLOCxID LLI WITH (NOLOCK) ON SL.StorerKey = LLI.StorerKey AND SL.SKU = LLI.SKU AND SL.LOC = LLI.LOC 
                       WHERE SL.StorerKey = @c_StorerKey
                           AND SL.SKU = @c_SKU
                           AND SL.LOC = @c_LOC                           
                           AND SL.LocationType IN ( 'CASE','PALLET','PICK')
                       GROUP BY 
                          SL.StorerKey, 
                          SL.SKU, 
                          SL.LOC,
                          SL.QtyLocationMinimum
                       HAVING (SUM(LLI.Qty) - SUM(LLI.QtyPicked) + SUM(LLI.PendingMoveIn)) <= SL.QtyLocationMinimum
                       )
        BEGIN
            PRINT '>>>>>> No Replenishment required, Do nothing'
            GOTO QUIT_SP
        END

        INSERT INTO #TempSKUxLOC
            ( StorerKey
            , SKU
            , LOC
            , ReplenishmentPriority
            , ReplenishmentSeverity
            , ReplenishmentCasecnt
            , LocationType
            , NoMixLottable02
            , Packkey
            , LOT
            , Selected
            , QtyReplen
            )
        SELECT SKUxLOC.StorerKey
         , SKUxLOC.SKU
         , SKUxLOC.LOC
         , SKUxLOC.ReplenishmentPriority
         , ReplenishmentSeverity = SKUxLOC.QtyLocationLimit - ((SKUxLOC.Qty - SKUxLOC.QtyPicked))
         , SKUxLOC.QtyLocationLimit
         , LOC.Locationtype
         , NoMixLottable02 = ISNULL(RTRIM(NoMixLottable02),'0')
         , SKU.Packkey
         , LOT=''
         , Selected=0
         , QtyReplen=0
        FROM SKUxLOC  WITH (NOLOCK)
            JOIN LOC  WITH (NOLOCK) ON (SKUxLOC.Loc = LOC.Loc)
            JOIN SKU  WITH (NOLOCK) ON (SKUxLOC.Storerkey = SKU.Storerkey AND SKUxLOC.Sku = SKU.Sku)
        WHERE SKUxLOC.StorerKey = @c_Storerkey
            AND LOC.FACILITY = @c_Facility
            AND SKUxLOC.Sku = @c_SKU   
            AND SKUxLOC.LOC = @c_LOC     
            AND LOC.LocationFlag NOT IN ('HOLD', 'DAMAGE')
            AND LOC.Status <> 'HOLD'            
            AND SKUxLOC.LOCationtype IN ( 'CASE','PALLET','PICK')
            AND ((SKUxLOC.Qty - SKUxLOC.QtyPicked)) <= SKUxLOC.QtyLocationMinimum
        ORDER BY SKUxLOC.StorerKey
            ,  SKUxLOC.SKU
            ,  SKUxLOC.LOC

        IF @@ROWCOUNT > 0
        BEGIN
            IF ISNULL(RTRIM(@c_ReplenishmentGroup), '') <> ''
            BEGIN
               EXECUTE nspg_GetKey
               'REPLENGROUP',
               9,
               @c_ReplenishmentGroup OUTPUT,
               @b_success OUTPUT,
               @n_err OUTPUT,
               @c_errmsg OUTPUT

               IF @b_success = 1
                  SET @c_ReplenishmentGroup = 'T' + @c_ReplenishmentGroup
            END 
        END

        IF @b_debug = 1
        BEGIN
            PRINT '>>>>>> #TempSKUxLOC'
            SELECT *
            FROM #TempSKUxLOC
        END

        /* Loop through SKUxLOC for the currentSKU, current storer */
        /* to pickup the next severity */
        DECLARE CUR_SKUxLOC CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
        SELECT CurrentStorer = StorerKey
            , CurrentSKU = SKU
            , CurrentLoc = LOC
            , CurrentSeverity        = ISNULL(SUM(ReplenishmentSeverity),0)
            , ReplenishmentPriority  = ReplenishmentPriority
            , ToLocationType         = LocationType
            , Packkey          = Packkey
            , NoMixLottable02  = NoMixLottable02
        FROM #TempSKUxLOC
        GROUP BY StorerKey
            ,  SKU
            ,  LOC
            ,  ReplenishmentPriority
            ,  LocationType
            ,  Packkey
            ,  NoMixLottable02
        ORDER BY StorerKey
              ,Sku
              ,ReplenishmentPriority
              ,Loc

        OPEN CUR_SKUxLOC

        FETCH NEXT FROM CUR_SKUxLOC INTO @c_CurrentStorer
                                    ,  @c_CurrentSKU
                                    ,  @c_CurrentLoc
                                    ,  @n_CurrentSeverity
                                    ,  @c_CurrentPriority
                                    ,  @c_ToLocationType
                                    ,  @c_Packkey
                                    ,  @c_NoMixLottable02
        WHILE @@Fetch_Status <> -1
        BEGIN
            IF EXISTS(SELECT 1
            FROM #SkipSKU
            WHERE SKU = @c_CurrentSKU)
            BEGIN
                GOTO NEXT_SKUxLOC
            END
            /* We now have a pickLOCation that needs to be replenished! */
            /* Figure out which LOCations in the warehouse to pull this product from */
            /* End figure out which LOCations in the warehouse to pull this product from */
            SET @c_FromLOC = ''
            SET @c_FromLot = ''
            SET @c_FromID  = ''
            SET @n_FromQty = 0
            SET @c_ToID    = ''

            SET @n_RemainingQty  = @n_CurrentSeverity

            SET @n_Pallet = 0.00
            SET @n_CaseCnt = 0.00

            SELECT @n_Pallet = ISNULL(Pallet,0)
               , @n_CaseCnt= ISNULL(CaseCnt,0)
               , @c_UOM    = P.PackUOM3
            FROM PACK P WITH (NOLOCK)
            WHERE P.Packkey = @c_Packkey

            IF @c_ToLocationType = 'PALLET' AND @n_Pallet = 0
            BEGIN
                IF @b_debug = 1
                  PRINT '<<< To Loc Type = Pallet by Pack.Pallet = 0 '

                GOTO NEXT_SKUxLOC
            END

            IF @c_ToLocationType = 'CASE' AND @n_CaseCnt = 0
            BEGIN
                IF @b_debug = 1
                    PRINT '<<< To Loc Type = CASE by Pack.CaseCnt = 0 '

                GOTO NEXT_SKUxLOC
            END

            IF @c_NoMixLottable02 = ''
            BEGIN
                SET @c_NoMixLottable02 = '0'
            END

            SET @n_FilterQty    = 1
            IF @c_ReplFullPallet = 'Y'
            BEGIN
                IF @n_Pallet = 0
                BEGIN
                    GOTO NEXT_SKUxLOC
                END
                SET @n_FilterQty = @n_Pallet
            END

            SET @n_RowID = 0
            SET @c_FromLot = ''

            IF @c_ReplOverflow = 'Y' AND @n_RemainingQty <= 0
            BEGIN
               SET @n_RemainingQty = @n_QtyPreAllocated
            END

            IF @b_debug = 1
            BEGIN
               PRINT '>>> CaseToPick: ' + @c_CaseToPick + ' ToLocationType: ' + @c_ToLocationType
            END

               DECLARE CUR_REPL CURSOR FAST_FORWARD READ_ONLY FOR
               SELECT LOTxLOCxID.LOT
                  , LOTxLOCxID.Loc
                  , LOTxLOCxID.ID
                  , LOTxLOCxID.Qty - LOTxLOCxID.QtyPicked - LOTxLOCxID.QtyAllocated - LOTxLOCxID.QtyReplen
                  , LOTxLOCxID.QtyAllocated
                  , LOTxLOCxID.QtyPicked
                  , LOTATTRIBUTE.Lottable02
               FROM LOT          WITH (NOLOCK)
                  JOIN LOTATTRIBUTE WITH (NOLOCK) ON (LOT.Lot        = LOTATTRIBUTE.LOT)
                  JOIN LOTxLOCxID   WITH (NOLOCK) ON (LOT.Lot        = LOTxLOCxID.Lot)
                  JOIN LOC          WITH (NOLOCK) ON (LOTxLOCxID.Loc = LOC.Loc)
               WHERE LOTxLOCxID.LOC <> @c_CurrentLoc
                  AND LOTxLOCxID.StorerKey = @c_CurrentStorer
                  AND LOTxLOCxID.SKU = @c_CurrentSku
                  AND LOTxLOCxID.qty - LOTxLOCxID.QtyPicked - LOTxLOCxID.QtyAllocated - LOTxLOCxID.QtyReplen >= 1
                  AND LOTxLOCxID.QtyExpected = 0
                  AND LOC.LocationFlag NOT IN ('DAMAGE', 'HOLD')
                  AND LOC.LocationType NOT IN ('CASE','PICK','PALLET')
                  AND LOC.Facility= @c_Facility
                  AND LOC.Status  <>'HOLD'
                  AND LOT.Status  = 'OK'
               ORDER BY 
                  LOTATTRIBUTE.Lottable04, 
                  LOTATTRIBUTE.Lottable05, 
                  CASE WHEN (LOTxLOCxID.Qty - LOTxLOCxID.QtyAllocated - LOTxLOCxID.QtyPicked - LOTxLOCxID.QtyReplen) < @n_Pallet
                           THEN 1
                           ELSE 2
                  END
                  ,  (LOTxLOCxID.Qty - LOTxLOCxID.QtyAllocated - LOTxLOCxID.QtyPicked)
                  ,  LOTATTRIBUTE.Lottable02

         OPEN CUR_REPL

         SELECT @n_CursorRows = @@CURSOR_ROWS  
         IF @n_CursorRows = -1
         BEGIN
            PRINT '>>> No Available LOT'
         END 

         FETCH NEXT FROM CUR_REPL INTO @c_FromLot
                                    ,  @c_FromLoc
                                    ,  @c_FromID
                                    ,  @n_FromQty
                                    ,  @n_QtyAllocated
                                    ,  @n_QtyPicked
                                    ,  @c_ReplLottable02

         WHILE @@Fetch_Status <> -1 AND @n_RemainingQty > 0
         BEGIN
               IF EXISTS( SELECT 1
               FROM #Replenishment AS r WITH(NOLOCK)
               WHERE r.Lot = @c_Fromlot
                  AND r.FromLOC = @c_FromLOC
                  AND r.ID = @c_FromID)
                  BEGIN
                  GOTO NEXT_CANDIDATE
               END

               IF @c_NoMixLottable02 = '1' AND @n_InvCnt = 0
               BEGIN
                  IF EXISTS ( SELECT 1
                  FROM #Replenishment
                  WHERE Storerkey = @c_CurrentStorer AND Sku = @c_CurrentSku AND ToLOC = @c_CurrentLoc
                     AND ReplLottable02 <> @c_ReplLottable02
                  GROUP BY Storerkey, Sku, ToLoc
                  HAVING COUNT(1) > 0)
                  BEGIN
                     GOTO NEXT_CANDIDATE
                  END
               END

               IF EXISTS(SELECT 1
                        FROM ID (NOLOCK)
                        WHERE ID = @c_FromID AND STATUS = 'HOLD')
               BEGIN
                  GOTO NEXT_CANDIDATE
               END

               SELECT @c_ReplValidationRules = SC.sValue
               FROM STORERCONFIG SC (NOLOCK)
                  JOIN CODELKUP CL (NOLOCK) ON SC.sValue = CL.Listname
               WHERE SC.StorerKey = @c_StorerKey
                  AND SC.Configkey = 'ReplenValidation'

               IF ISNULL(@c_ReplValidationRules,'') <> ''
               BEGIN
                  EXEC isp_REPL_ExtendedValidation @c_fromlot = @c_fromlot
                                             ,  @c_FromLOC = @c_FromLOC
                                             ,  @c_FromID  = @c_FromID
                                             ,  @c_ReplValidationRules=@c_ReplValidationRules
                                             ,  @b_Success = @b_Success OUTPUT
                                             ,  @c_ErrMsg  = @c_ErrMsg OUTPUT
                  IF @b_Success = 0
                  BEGIN
                     GOTO NEXT_CANDIDATE
                  END
               END

               IF @c_ToLocationType = 'PALLET'
               BEGIN
                  IF @b_debug = 1
                  BEGIN
                     PRINT '>>> ToLocationType = PALLET'
                  END

                  IF @n_FromQty < @n_Pallet
                  BEGIN
                     GOTO NEXT_CANDIDATE
                  END

                  IF @n_FromQty > @n_RemainingQty
                  BEGIN
                     SET @n_FromQty = FLOOR(@n_RemainingQty/@n_Pallet) * @n_Pallet
                  END
                  ELSE
                  BEGIN
                     SET @n_FromQty = FLOOR(@n_FromQty/@n_Pallet) * @n_Pallet
                  END
               END
               ELSE IF @c_ToLocationType = 'CASE'
               BEGIN
                  IF @b_debug = 1
                  BEGIN
                     PRINT '>>> ToLocationType = CASE'
                  END
                  IF @c_ReplAllPalletQty = 'N'
                  BEGIN
                     IF @n_FromQty < @n_CaseCnt
                     BEGIN
                        GOTO NEXT_CANDIDATE
                     END
                  END

                  SELECT @c_LottableName = ''
                  SELECT TOP 1
                     @c_LottableName = Code
                  FROM CODELKUP (NOLOCK)
                  WHERE Listname = 'REPLENLOT'
                     AND Storerkey = @c_StorerKey
                  ORDER BY Code

                  SET @c_LottableValue = ''
                  IF ISNULL(@c_LottableName,'') <> ''
                  BEGIN
                     SET @c_SQL = N'SELECT TOP 1 @c_LottableValue = LA.' + RTRIM(LTRIM(@c_LottableName))  +
                                 N' FROM LOTATTRIBUTE LA (NOLOCK) ' + 
                                 N' WHERE LA.StorerKey = @c_Storerkey ' + 
                                 N' AND LA.lot = @c_FromLot  '

                     EXEC sp_executesql @c_SQL,
                     N'@c_LottableValue NVARCHAR(30) OUTPUT, @c_Storerkey NVARCHAR(15), @c_FromLot NVARCHAR(20)',
                     @c_LottableValue OUTPUT,
                     @c_Storerkey,
                     @c_FromLot
                  END

                  IF @b_debug = 1
                  BEGIN
                     PRINT '>>> SQL: ' + @c_SQL
                  END 

                  IF ISNULL(@c_LottableValue,'') <> ''
                  BEGIN
                     GOTO NEXT_CANDIDATE
                  END

                  --CS01 END

                  IF @n_FromQty > @n_RemainingQty
                  BEGIN
                     IF @c_CaseToPick = 'Y'
                     BEGIN
                        IF CEILING(@n_RemainingQty/@n_CaseCnt) * @n_CaseCnt > @n_FromQty
                           SET @n_FromQty = FLOOR(@n_RemainingQty/@n_CaseCnt) * @n_CaseCnt
                        ELSE
                           SET @n_FromQty = CEILING(@n_RemainingQty/@n_CaseCnt) * @n_CaseCnt
                     END
                     ELSE
                     BEGIN
                        IF @c_ReplFullPallet = 'Y'
                        BEGIN
                           IF @n_RemainingQty >= @n_Pallet
                           BEGIN
                              SET @n_FromQty = FLOOR(@n_RemainingQty/@n_Pallet) * @n_Pallet
                           END
                           ELSE
                           BEGIN
                              SET @n_FromQty = 0
                           END
                        END
                        ELSE
                        BEGIN
                           IF @c_ReplAllPalletQty = 'N'
                           BEGIN
                              SET @n_FromQty = 0
                           END
                        END
                     END
                  END
                  ELSE
                  BEGIN
                     IF @c_ReplAllPalletQty = 'N'
                     BEGIN
                        IF @n_FromQty < @n_Pallet
                        BEGIN
                           SET @n_FromQty = FLOOR(@n_FromQty/@n_CaseCnt) * @n_CaseCnt
                        END
                        ELSE
                        BEGIN
                           SET @n_FromQty = FLOOR(@n_FromQty/@n_Pallet) * @n_Pallet
                        END
                     END
                  END
               END
            ELSE IF @c_ToLocationType = 'PICK' AND @c_CaseToPick = 'Y'
            BEGIN
               IF @b_debug = 1
               BEGIN
                  PRINT '>>> ToLocationType = PICK'
               END

               IF @n_FromQty > @n_RemainingQty
                  IF CEILING(@n_RemainingQty/@n_CaseCnt) * @n_CaseCnt > @n_FromQty
                     SET @n_FromQty = FLOOR(@n_RemainingQty/@n_CaseCnt) * @n_CaseCnt
                  ELSE
                     SET @n_FromQty = CEILING(@n_RemainingQty/@n_CaseCnt) * @n_CaseCnt
               ELSE
                  SET @n_FromQty = FLOOR(@n_FromQty/@n_CaseCnt) * @n_CaseCnt
               END -- IF @c_ToLocationType = 'PICK' AND @c_CaseToPick = 'Y'

               IF @n_FromQty > 0
               BEGIN
                  SELECT @n_MaxCapacity = 0,
                     @n_QtyReplen   = 0

                  SELECT @n_MaxCapacity = tsl.ReplenishmentCasecnt,
                         @n_QtyReplen   = SUM(tsl.QtyReplen)
                  FROM #TempSKUxLOC AS tsl WITH(NOLOCK)
                  WHERE StorerKey = @c_CurrentStorer
                     AND SKU = @c_CurrentSKU
                     AND LOC = @c_CurrentLoc
                  GROUP BY tsl.ReplenishmentCasecnt

                  IF @b_debug = 1
                  BEGIN
                     PRINT '>>> @c_CurrentLoc: ' + @c_CurrentLoc
                     PRINT '>>> @n_MaxCapacity: ' + CAST(@n_MaxCapacity AS VARCHAR) + ', @n_QtyReplen: ' + CAST(@n_QtyReplen AS VARCHAR) + ', @n_FromQty: ' + CAST(@n_FromQty AS VARCHAR)
                  END

                  IF (@n_QtyReplen + @n_FromQty > @n_MaxCapacity) AND (@n_QtyReplen > 0)
                  BEGIN
                     IF @b_debug = 1
                     BEGIN
                        PRINT '>>> ' + CAST((@n_QtyReplen + @n_FromQty) AS VARCHAR) +
                              ' Exceeded MaxCapacity. Get Next Location '
                     END

                     -- SELECT Other Location can fit the qty
                     SET @c_NextLOC = ''
                     SELECT TOP 1
                           @c_NextLOC = ISNULL(tsl.LOC,'')
                     FROM #TempSKUxLOC AS tsl WITH(NOLOCK)
                     WHERE StorerKey = @c_CurrentStorer
                           AND SKU = @c_CurrentSKU
                           AND LOC <> @c_CurrentLoc
                     GROUP BY SKU, LOC
                     HAVING SUM(@n_QtyReplen) + @n_FromQty > @n_MaxCapacity
                     ORDER BY SUM(@n_QtyReplen), LOC

                     IF @b_debug = 1
                     BEGIN
                        PRINT '>>> @c_NextLOC: ' + @c_NextLOC
                     END

                     -- If found, suggest to replen to this location. Otherwise do nothing
                     IF @c_NextLOC <> ''
                     SET @c_CurrentLoc = @c_NextLOC
                  END
               END -- @n_FromQty > 0

               --SET @n_RemainingQty = @n_RemainingQty - @n_FromQty -- (SWT01)
               IF @n_FromQty > @n_RemainingQty
                  SET @n_RemainingQty = 0
               ELSE
                  SET @n_RemainingQty = @n_RemainingQty - @n_FromQty

               IF @n_FromQty > 0
               BEGIN
                  INSERT #Replenishment
                     (
                     StorerKey
                     , SKU
                     , FromLOC
                     , ToLOC
                     , Lot
                     , Id
                     , Qty
                     , UOM
                     , PackKey
                     , Priority
                     , QtyMoved
                     , QtyInPickLOC
                     , ReplLottable02
                     )
                  VALUES
                     (
                       @c_CurrentStorer
                     , @c_CurrentSKU
                     , @c_FromLOC
                     , @c_CurrentLoc
                     , @c_FromLot
                     , @c_FromID
                     , @n_FromQty
                     , @c_UOM
                     , @c_Packkey
                     , @c_CurrentPriority
                     , @n_QtyAllocated
                     , @n_QtyPicked
                     , @c_ReplLottable02
                     )
                  IF @b_debug = 1
                  BEGIN
                     SELECT 'INSERTED : ' as Title, @c_CurrentSKU ' SKU', @c_fromlot 'LOT', @c_CurrentLoc 'LOC', @c_FromID 'ID',
                           @n_FromQty 'Qty'
                  END

                  UPDATE #TempSKUxLOC
                  SET SELECTED = 1, QtyReplen = QtyReplen + @n_FromQty
                     WHERE StorerKey = @c_CurrentStorer
                     AND SKU = @c_CurrentSKU
                     AND LOC = @c_CurrentLoc
                     AND LOT = @c_FromLot

               END -- IF @n_FromQty > 0

               IF @b_debug = 1
               BEGIN
                  SELECT @c_CurrentSKU ' SKU', @c_CurrentLoc 'LOC', @c_CurrentPriority 'priority', @n_currentfullcase 'full case', @n_CurrentSeverity 'severity'
                  SELECT @n_RemainingQty '@n_RemainingQty', @c_CurrentLoc + ' SKU = ' + @c_CurrentSKU, @c_fromlot 'from lot', @c_FromID
               END

               NEXT_CANDIDATE:
               FETCH NEXT FROM CUR_REPL INTO @c_FromLot
                                       ,  @c_FromLoc
                                       ,  @c_FromID
                                       ,  @n_FromQty
                                       ,  @n_QtyAllocated
                                       ,  @n_QtyPicked
                                       ,  @c_ReplLottable02
         END
         -- LOT
         CLOSE CUR_REPL
         DEALLOCATE CUR_REPL

        NEXT_SKUxLOC:
        -- (SWT01)
        IF @n_RemainingQty <= 0 AND NOT EXISTS(SELECT 1
            FROM #SkipSKU
            WHERE SKU = @c_CurrentSKU)
         BEGIN
            INSERT INTO #SkipSKU
                (SKU)
            VALUES
                (@c_CurrentSKU)
        END

        FETCH NEXT FROM CUR_SKUxLOC INTO @c_CurrentStorer
                                       ,  @c_CurrentSKU
                                       ,  @c_CurrentLoc
                                       ,  @n_CurrentSeverity
                                       ,  @c_CurrentPriority
                                       ,  @c_ToLocationtype
                                       ,  @c_Packkey
                                       ,  @c_NoMixLottable02
    END
    -- -- FOR SKUxLOC
    CLOSE CUR_SKUxLOC
    DEALLOCATE CUR_SKUxLOC

    IF @b_Debug = 1
    BEGIN
      SELECT * FROM #Replenishment R
    END 
    /* Insert Into Replenishment Table Now */
    DECLARE CUR1 CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT R.FromLoc
            , R.Id
            , R.ToLoc
            , R.Sku
            , R.Qty
            , R.StorerKey
            , R.Lot
            , R.PackKey
            , R.Priority
            , R.UOM
    FROM #Replenishment R

    OPEN CUR1
    FETCH NEXT FROM CUR1 INTO @c_FromLOC
                              , @c_FromID
                              , @c_CurrentLoc
                              , @c_CurrentSKU
                              , @n_FromQty
                              , @c_CurrentStorer
                              , @c_FromLot
                              , @c_PackKey
                              , @c_Priority
                              , @c_UOM
      WHILE @@FETCH_STATUS <> -1
      BEGIN
         IF @c_ReplenType = 'R'  
         BEGIN
            EXECUTE nspg_GetKey
                  'REPLENISHKEY'
               ,  10
               ,  @c_ReplenishmentKey OUTPUT
               ,  @b_success          OUTPUT
               ,  @n_err              OUTPUT
               ,  @c_errmsg           OUTPUT

           IF NOT @b_success = 1
           BEGIN
               BREAK
           END

           IF @b_success = 1
           BEGIN
               IF EXISTS( SELECT 1
               FROM LOC WITH (NOLOCK)
               WHERE Loc = @c_CurrentLoc
                   AND LoseId = '1' )
               BEGIN
                   SET @c_ToID = ''
               END
               ELSE
               BEGIN
                   SET @c_ToID = @c_FromID
               END


               INSERT INTO REPLENISHMENT
                   (
                   Replenishmentgroup
                   , ReplenishmentKey
                   , StorerKey
                   , Sku
                   , FromLoc
                   , ToLoc
                   , Lot
                   , Id
                   , Qty
                   , UOM
                   , PackKey
                   , Confirmed
                   , RefNo
                   , QtyReplen
                   , Wavekey
                   , PendingMoveIn
                   , ToID
                   )
               VALUES
                   (
                    @c_ReplenishmentGroup
                  , @c_ReplenishmentKey
                  , @c_CurrentStorer
                  , @c_CurrentSKU
                  , @c_FromLOC
                  , @c_CurrentLoc
                  , @c_FromLot
                  , @c_FromID
                  , @n_FromQty
                  , @c_UOM
                  , @c_PackKey
                  , 'N'
                  , ''
                  , @n_FromQty
                  , @c_Wavekey
                  , @n_FromQty
                  , @c_ToID
                  )
                  SELECT @n_err = @@ERROR  
                  IF @n_err <> 0  
                  BEGIN  
                     SELECT @n_continue = 3  
                     SELECT @c_ErrMsg = CONVERT(CHAR(250) ,@n_err),@n_err = 62081       
                     SELECT @c_ErrMsg = 'NSQL'+CONVERT(CHAR(5) ,@n_err)+  
                              ': Insert Into Replenishment Failed (isp_ODMRPL01)'   
                           +' ( '+' SQLSvr MESSAGE='+ TRIM(@c_ErrMsg) +' ) '  
            END  
            END -- IF @b_success = 1
         END -- IF @c_ReplenType = 'R'  
         IF @c_ReplenType = 'T'
         BEGIN
            SELECT @c_FromLogicalLoc = LOC.LogicalLocation 
            FROM LOC WITH (NOLOCK)
            WHERE LOC = @c_FromLOC

            SELECT @c_ToLogicalLoc = LOC.LogicalLocation 
            FROM LOC WITH (NOLOCK)
            WHERE LOC = @c_CurrentLoc
            
            SELECT TOP 1 @c_FromAreaKey = AREADETAIL.Areakey  
            FROM LOC (NOLOCK)  
            JOIN AREADETAIL ON (LOC.PutawayZone = AREADETAIL.PutawayZone)  
            WHERE LOC.Loc = @c_FromLOC  

            SELECT @b_success = 1  
            EXECUTE nspg_getkey  
            'TaskDetailKey'  
            , 10  
            , @c_TaskDetailKey OUTPUT  
            , @b_success OUTPUT  
            , @n_err OUTPUT  
            , @c_errmsg OUTPUT  
            IF NOT @b_success = 1  
            BEGIN  
               SELECT @n_continue = 3           
               SELECT @n_err = 62080  
               SELECT @c_errmsg = 'isp_ODMRPL01: ' + Trim(@c_errmsg)  
            END  

            INSERT INTO TASKDETAIL  
            (  
               TaskDetailKey
               ,TaskType
               ,Storerkey
               ,Sku
               ,Lot
               ,UOM
               ,UOMQty
               ,Qty
               ,FromLoc
               ,LogicalFromLoc
               ,FromID
               ,ToLoc
               ,LogicalToLoc
               ,ToID
               ,Caseid
               ,PickMethod
               ,Status
               ,StatusMsg
               ,Priority
               ,SourcePriority
               ,Holdkey
               ,UserKey
               ,UserPosition
               ,UserKeyOverRide
               ,SourceType
               ,SourceKey
               ,Message03
               ,SystemQty
               ,RefTaskKey
               ,AreaKey
               ,FinalLOC
               ,FinalID
               ,Groupkey
               ,QtyReplen
            )  
            VALUES  
            (  
                @c_TaskDetailKey  
               ,'VNAOUT'
               ,@c_CurrentStorer
               ,@c_CurrentSKU
               ,@c_FromLot
               ,1
               ,@n_FromQty
               ,@n_FromQty
               ,@c_FromLOC
               ,@c_FromLogicalLoc
               ,@c_FromID
               ,@c_CurrentLoc
               ,@c_ToLogicalLoc
               ,@c_FromID
               ,'' -- Case ID
               ,'FP' -- PickMethod
               ,'Q' -- Status
               , '' -- StatusMsg
               ,'9' -- Priority
               ,'' -- Source Priority
               ,'' -- Hold Key
               ,'' -- UserKey
               ,'1' -- User Position
               ,'' -- UserKeyOverRide
               ,'isp_ODMRPL01'
               , @c_ReplenishmentKey -- SourceKey
               ,'RPF'
               ,@n_FromQty
               ,'' -- RefTaskKey
               ,@c_FromAreaKey
               ,@c_CurrentLoc
               ,@c_FromID
               ,@c_TaskDetailKey -- Groupkey
               ,@n_FromQty -- Qty Replen, set to Zero, otherwise will double the qty since replenishment add trigger already calculated.
            )    
        
            SELECT @n_err = @@ERROR  
            IF @n_err <> 0  
            BEGIN  
               SELECT @n_continue = 3  
               SELECT @c_ErrMsg = CONVERT(CHAR(250) ,@n_err),@n_err = 62081       
               SELECT @c_ErrMsg = 'NSQL'+CONVERT(CHAR(5) ,@n_err)+  
                        ': Insert Into TaskDetail Failed (isp_ODMRPL01)'   
                     +' ( '+' SQLSvr MESSAGE='+ TRIM(@c_ErrMsg) +' ) '  
            END  

            -- Force Calculated Pending Move In Qty
            SET @n_Err = 0 
            EXEC rdt.rdt_Putaway_PendingMoveIn   
                   @cUserName = ''  
                  ,@cType = 'LOCK'  
                  ,@cFromLoc = @c_FromLOC  
                  ,@cFromID = @c_FromID  
                  ,@cSuggestedLOC = @c_CurrentLoc  
                  ,@cStorerKey = @c_CurrentStorer  
                  ,@nErrNo = @n_Err OUTPUT  
                  ,@cErrMsg = @c_Errmsg OUTPUT  
                  ,@cSKU = @c_CurrentSKU  
                  ,@nPutawayQTY    = @n_FromQty  
                  ,@cFromLOT       = @c_FromLot  
                  ,@cTaskDetailKey = @c_TaskdetailKey  
                  ,@nFunc = 0  
                  ,@nPABookingKey = 0  
                  ,@cMoveQTYAlloc = '1'  
                  ,@cMoveQTYReplen='1'
                                                                                                                     
            --SET @n_err = @@ERROR  -- (Wan02)                                                                               
                                                                                                                     
            IF @n_err <> 0                                                                                     
            BEGIN                                                                                              
               SELECT @n_continue = 3  
                     ,@n_err = 67994   
               SELECT @c_errmsg = 'NSQL'+CONVERT(CHAR(5) ,@n_err)+  
                        ':  Execute rdt.rdt_Putaway_PendingMoveIn Failed! (isp_ODMRPL01)'  
            END                                             

         END -- IF @c_ReplenType = 'T'

        FETCH NEXT FROM CUR1 INTO @c_FromLOC
                                 , @c_FromID
                                 , @c_CurrentLoc
                                 , @c_CurrentSKU
                                 , @n_FromQty
                                 , @c_CurrentStorer
                                 , @c_FromLot
                                 , @c_PackKey
                                 , @c_Priority
                                 , @c_UOM
    END
    -- While
    CLOSE CUR1
    DEALLOCATE CUR1
-- End Insert Replenishment
END

QUIT_SP:

   IF @n_continue = 3
   BEGIN
    IF @@TRANCOUNT > 0
      BEGIN
        ROLLBACK TRAN
    END
    RAISERROR (@c_errmsg, 16, 1) WITH SETERROR
   END
   ELSE
   BEGIN
    WHILE @@TRANCOUNT > 0
      BEGIN
        COMMIT TRAN
    END
   END

   WHILE @@TRANCOUNT < @n_StartTCnt
   BEGIN
      BEGIN TRAN
   END
END
GO
GRANT EXECUTE ON [dbo].[isp_ODMRPL01] TO [NSQL]
GO
