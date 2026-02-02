SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/**************************************************************************/
/* Stored Procedure: msp_SerialNoMoveCheck                                */
/* Creation Date:                                                         */
/* Copyright: Mearsk                                                      */
/* Written by:                                                            */
/*                                                                        */
/* Purpose: Generic SerialNo Move update                                  */
/*                                                                        */
/* Called By:                                                             */
/*                                                                        */
/* Version: 1.1                                                           */
/*                                                                        */
/* Data Modifications:                                                    */
/*                                                                        */
/* Updates:                                                               */
/* Date        Author   Ver.  Purposes                                    */
/* 2025-04-04  Wan01    1.1   UWP-31258-FCR-822 Partial Pallet Serial No  */
/*                            Move                                        */
/* 10-Oct-2025  SSA01   1.2   UWP-42248 -Enhanced session management      */
/* 2025-10-20  Michael  1.3   FCR-8378-StrCfg SerialNoUpdateLotLocID(ML01)*/
/**************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[msp_SerialNoMoveCheck]
     @c_ItrnKey      NVARCHAR(10)
   , @c_StorerKey    NVARCHAR(15)
   , @c_Sku          NVARCHAR(20)
   , @c_Lot          NVARCHAR(10)
   , @c_Fromloc      NVARCHAR(10)
   , @c_FromID       NVARCHAR(18)
   , @c_ToLoc        NVARCHAR(10)
   , @c_ToID         NVARCHAR(18)
   , @c_Packkey      NVARCHAR(10)
   , @c_Status       NVARCHAR(10)
   , @n_Casecnt      INT       -- Casecount being inserted
   , @n_Innerpack    INT       -- innerpacks being inserted
   , @n_Qty          INT       -- QTY (Most important) being inserted
   , @n_Pallet       INT       -- pallet being inserted
   , @f_Cube         FLOAT     -- cube being inserted
   , @f_Grosswgt     FLOAT     -- grosswgt being inserted
   , @f_Netwgt       FLOAT     -- netwgt being inserted
   , @f_Otherunit1   FLOAT     -- other units being inserted.
   , @f_Otherunit2   FLOAT     -- other units being inserted too.
   , @c_Lottable01   NVARCHAR(18) = ''
   , @c_Lottable02   NVARCHAR(18) = ''
   , @c_Lottable03   NVARCHAR(18) = ''
   , @d_Lottable04   DATETIME     = NULL
   , @d_Lottable05   DATETIME     = NULL
   , @c_Lottable06   NVARCHAR(30) = ''   
   , @c_Lottable07   NVARCHAR(30) = ''   
   , @c_Lottable08   NVARCHAR(30) = ''   
   , @c_Lottable09   NVARCHAR(30) = ''   
   , @c_Lottable10   NVARCHAR(30) = ''   
   , @c_Lottable11   NVARCHAR(30) = ''   
   , @c_Lottable12   NVARCHAR(30) = ''   
   , @d_Lottable13   DATETIME = NULL     
   , @d_Lottable14   DATETIME = NULL     
   , @d_Lottable15   DATETIME = NULL     
   , @b_Success      INT        OUTPUT
   , @n_Err          INT        OUTPUT
   , @c_Errmsg       NVARCHAR(250)  OUTPUT
   , @c_MoveRefKey   NVARCHAR(10)  = ''     
   , @c_Channel      NVARCHAR(20) = ''      
   , @n_Channel_ID   BIGINT = 0 OUTPUT      
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE 
      @c_SerialNoCapture   NVARCHAR(1) = ''
     ,@c_SerialNoKey       NVARCHAR(10) = ''
     ,@n_Continue          INT = 1

     ,@n_SerialQty         INT = 0                                                  --(Wan01)   
     ,@c_SerialNo          NVARCHAR(30) = ''                                        --(Wan01)   
     ,@c_Facility          NVARCHAR(15) = ''        --ML01
     ,@c_SerialNoUpdateLotLocID NVARCHAR(30) = ''   --ML01
     ,@c_LoseUCC           NVARCHAR(1)  = ''        --ML01

   --ML01-S
   SELECT @c_Facility = Facility
   FROM LOC (NOLOCK)
   WHERE Loc = @c_FromLoc

   SELECT @c_SerialNoUpdateLotLocID = dbo.fnc_GetRight(@c_Facility, @c_Storerkey, '', 'SerialNoUpdateLotLocID')
   --ML01-E

   SELECT @c_SerialNoCapture = SerialNoCapture 
   FROM dbo.SKU WITH (NOLOCK) 
   WHERE StorerKey = @c_StorerKey 
   AND SKU = @c_Sku

   IF @c_SerialNoCapture NOT IN ('1','3') 
   AND @c_SerialNoCapture NOT IN ('2')   --ML01
      GOTO Quit_SP

   IF @n_Continue IN (1,2)
   BEGIN
      IF @c_FromID <> @c_ToID AND @c_Lot <> ''
      OR @c_FromLoc <> @c_ToLoc AND @c_Lot <> ''   --ML01
      BEGIN
         IF EXISTS(SELECT 1 FROM dbo.SerialNo SN WITH (NOLOCK) 
                  WHERE SN.Lot = @c_Lot
                  AND (SN.ID <> '' OR SN.Loc = @c_FromLoc) --ML01
                  AND SN.ID = @c_FromID)
         BEGIN              
            --ML01-S
            SET @c_LoseUCC = ''
            SELECT @c_LoseUCC = LoseUCC
              FROM LOC (NOLOCK)
             WHERE Loc = @c_ToLoc
            --ML01-E

            DECLARE CUR_SWAP_ID CURSOR LOCAL FAST_FORWARD READ_ONLY FOR 
            SELECT SN.SerialNoKey
                  ,SN.SerialNo                                                      --(Wan01)
                  ,SN.Qty                                                           --(Wan01)
            FROM dbo.SerialNo SN WITH (NOLOCK) 
            WHERE SN.LOT = @c_Lot
            AND SN.ID = @c_FromID
            AND (SN.ID <> '' OR SN.Loc = @c_FromLoc) --ML01
            AND SN.StorerKey = @c_StorerKey
            AND SN.SKU = @c_Sku
            -- ORDER BY SN.SerialNoKey
              
            OPEN CUR_SWAP_ID
              
            FETCH NEXT FROM CUR_SWAP_ID INTO @c_SerialNoKey, @c_SerialNo            --(Wan01)
                                          ,  @n_SerialQty                           --(Wan01)
              
            WHILE @@FETCH_STATUS = 0
            BEGIN
               UPDATE dbo.SerialNo WITH (ROWLOCK)
                  SET ID = @c_ToID, EditDate=dbo.fnc_GetDate() , EditWho=dbo.fnc_GetUserName()      --(SSA01)
                    , Loc = CASE WHEN @c_SerialNoUpdateLotLocID = '1' THEN @c_ToLoc ELSE Loc END    --ML01
                    , UCCNo = CASE WHEN @c_LoseUCC = '1' THEN '' ELSE UCCNo END                     --ML01
               WHERE SerialNoKey = @c_SerialNoKey 
               SELECT @n_err = @@ERROR
               IF @n_err <> 0
               BEGIN
                  SELECT @n_Continue = 3
                  SELECT @n_err = 500301
                  SELECT @c_errmsg='NSQL'+CONVERT(char(6),@n_err)+': Update Failed On Table SerialNo. (msp_SerialNoMoveCheck)' 
                           + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTrim(@c_ErrMsg),'') + ' ) '
                  BREAK
               END

               IF @n_Continue = 1                                                   --(Wan01)
               BEGIN
                  EXEC [dbo].[ispITrnSerialNoMove]
                    @c_ItrnKey      = @c_ItrnKey   
                  , @c_TranType     = 'MV'   
                  , @c_StorerKey    = @c_StorerKey 
                  , @c_SKU          = @c_SKU       
                  , @c_SerialNo     = @c_SerialNo  
                  , @c_FromID       = @c_FromID    
                  , @c_ToID         = @c_ToID      
                  , @n_QTY          = @n_SerialQty        
                  , @c_SourceKey    = '' 
                  , @c_SourceType   = ''
                  , @b_Success      = @b_Success    OUTPUT
                  , @n_Err          = @n_Err        OUTPUT
                  , @c_Errmsg       = @c_Errmsg     OUTPUT
               END

               FETCH NEXT FROM CUR_SWAP_ID INTO @c_SerialNoKey, @c_SerialNo         --(Wan01)
                                             ,  @n_SerialQty                        --(Wan01)
            END
              
            CLOSE CUR_SWAP_ID
            DEALLOCATE CUR_SWAP_ID
         END
           
      END
   END -- @c_Continue=1

   Quit_SP:
   IF @n_Continue = 3  -- Error Occured - Process And Return
   BEGIN
      SELECT @b_success = 0
      DECLARE @n_IsRDT INT
      EXECUTE RDT.rdtIsRDT @n_IsRDT OUTPUT

      IF @n_IsRDT = 1
      BEGIN
         -- RDT cannot handle rollback (blank XML will generate). So we are not going to issue a rollback here
         -- Instead we commit and raise an error back to parent, let the parent decide

         -- Commit until the level we begin with
         -- Notes: Original codes do not have COMMIT TRAN, error will be handled by parent
         -- WHILE @@TRANCOUNT > @n_starttcnt
         --    COMMIT TRAN

         -- Raise error with severity = 10, instead of the default severity 16.
         -- RDT cannot handle error with severity > 10, which stop the processing after executed this trigger
         RAISERROR (@n_err, 10, 1) WITH SETERROR

         -- The RAISERROR has to be last line, to ensure @@ERROR is not getting overwritten
      END
      ELSE
      BEGIN
         EXECUTE dbo.nsp_logerror @n_err, @c_errmsg, 'msp_SerialNoMoveCheck'
         RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
         RETURN -1
      END
   END
   ELSE
   BEGIN
      /* Error Did Not Occur , Return Normally */
      SELECT @b_success = 1
      RETURN 0
   END
   /* End Return Statement */
END -- Create Proc 
GO

GRANT EXECUTE ON [dbo].[msp_SerialNoMoveCheck] TO NSQL  
GO 
