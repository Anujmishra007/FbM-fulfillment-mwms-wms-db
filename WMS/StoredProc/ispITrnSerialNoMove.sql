SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/**************************************************************************/
/* Stored Procedure: ispITrnSerialNoMove                                  */
/* Creation Date: 2025-04-08                                              */
/* Copyright: Mearsk Logistics                                            */
/* Written by: Wan                                                        */
/*                                                                        */
/* Purpose: INsert ItrnSerialNo Whne Move update                          */
/*                                                                        */
/* Called By:                                                             */
/*                                                                        */
/* Version: 1.0                                                           */
/*                                                                        */
/* Data Modifications:                                                    */
/*                                                                        */
/* Updates:                                                               */
/* Date        Author   Ver.  Purposes                                    */
/* 2025-04-08  Wan      1.0   UWP-31258-FCR-822 Partial Pallet Serial No  */
/*                            Move                                        */
/* 2025-10-20  Michael  1.1   FCR-8378-StrCfg SerialNoUpdateLotLocID(ML01)*/
/**************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[ispITrnSerialNoMove]
  @c_ItrnKey      NVARCHAR(10)
, @c_TranType     NVARCHAR(10) = 'MV'  
, @c_StorerKey    NVARCHAR(15) 
, @c_SKU          NVARCHAR(20) 
, @c_SerialNo     NVARCHAR(30) 
, @c_FromID       NVARCHAR(18) = ''
, @c_ToID         NVARCHAR(18) = ''
, @n_QTY          INT          = 1  
, @c_SourceKey    NVARCHAR(20) = ''
, @c_SourceType   NVARCHAR(30) = ''
, @b_Success      INT          = 1  OUTPUT
, @n_Err          INT          = 0  OUTPUT
, @c_Errmsg       NVARCHAR(250)= '' OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE 
      @n_StartTranCount    INT   = @@TRANCOUNT
     ,@c_SerialNoKey       NVARCHAR(10) = ''
     ,@n_Continue          INT          = 1

     ,@c_Lot               NVARCHAR(10) = ''                                      
     ,@c_Loc               NVARCHAR(10) = ''                                      
     ,@c_FromLoc           NVARCHAR(10) = ''   --ML01
     ,@c_ID                NVARCHAR(18) = ''                                      
     ,@c_lottable01        NVARCHAR(18) = ''                                      
     ,@c_lottable02        NVARCHAR(18) = ''                                      
     ,@c_lottable03        NVARCHAR(18) = ''                                      
     ,@d_lottable04        DATETIME     = NULL                                    
     ,@d_lottable05        DATETIME     = NULL                                    
     ,@c_lottable06        NVARCHAR(30) = ''                                      
     ,@c_lottable07        NVARCHAR(30) = ''                                      
     ,@c_lottable08        NVARCHAR(30) = ''                                      
     ,@c_lottable09        NVARCHAR(30) = ''                                      
     ,@c_lottable10        NVARCHAR(30) = ''                                      
     ,@c_lottable11        NVARCHAR(30) = ''                                      
     ,@c_lottable12        NVARCHAR(30) = ''                                      
     ,@d_lottable13        DATETIME     = NULL                                    
     ,@d_lottable14        DATETIME     = NULL                                    
     ,@d_lottable15        DATETIME     = NULL                                    
     ,@c_Status            NVARCHAR(10) = ''                                      
     ,@c_UCCNo             NVARCHAR(20) = ''                                      
 
   IF @c_SourceType = ''
   BEGIN
      SELECT @c_SourceKey = i.Sourcekey
            ,@c_SourceType= i.SourceType
      FROM ITRN i (NOLOCK)
      WHERE ItrnKey = @c_ItrnKey
   END

   SELECT 
        @c_Lot    = Lot                                                        
      , @c_Status = [Status]
      , @c_UCCNo  = ISNULL(UCCNo,'')
   FROM SERIALNO WITH (NOLOCK)
   WHERE Storerkey  = @c_Storerkey
   AND   SerialNo   = @c_SerialNo

   IF @c_Lot <> ''
   BEGIN
      SELECT  @c_lottable01 = la.lottable01
            , @c_lottable02 = la.lottable02
            , @c_lottable03 = la.lottable03
            , @d_lottable04 = la.lottable04
            , @d_lottable05 = la.lottable05
            , @c_lottable06 = la.lottable06
            , @c_lottable07 = la.lottable07
            , @c_lottable08 = la.lottable08
            , @c_lottable09 = la.lottable09
            , @c_lottable10 = la.lottable10
            , @c_lottable11 = la.lottable11
            , @c_lottable12 = la.lottable12
            , @d_lottable13 = la.lottable13
            , @d_lottable14 = la.lottable14
            , @d_lottable15 = la.lottable15
      FROM LOTATTRIBUTE la (NOLOCK)
      WHERE la.Lot = @c_lot
   END

   --ML01-S
   SELECT @c_FromLoc = ISNULL(FromLoc,'')
        , @c_Loc     = ISNULL(ToLoc,'')
   FROM ITRN (NOLOCK)
   WHERE ItrnKey = @c_ItrnKey

   IF @@ROWCOUNT = 0
   BEGIN
      IF ISNULL(@c_FromID,'')<>''
      BEGIN
         SELECT TOP 1 @c_FromLoc = ISNULL(Loc,'')
         FROM LOTxLOCxID (NOLOCK)
         WHERE Storerkey = @c_StorerKey
           AND Sku = @c_Sku
           AND ID = @c_FromID
      END

      IF ISNULL(@c_ToID,'')<>''
      BEGIN
         SELECT TOP 1 @c_Loc = ISNULL(Loc,'')
         FROM LOTxLOCxID (NOLOCK)
         WHERE Storerkey = @c_StorerKey
           AND Sku = @c_Sku
           AND ID = @c_ToID
      END
   END
   --ML01-E

   INSERT INTO ITrnSerialNo (ITrnKey, TranType, StorerKey, SKU, SerialNo, QTY, SourceKey, SourceType
                           , Lot, Loc, ID
                           , Lottable01, Lottable02, Lottable03, Lottable04, Lottable05
                           , Lottable06, Lottable07, Lottable08, Lottable09, Lottable10
                           , Lottable11, Lottable12, Lottable13, Lottable14, Lottable15
                           , Channel, Channel_ID, UCCNo, FromID
                           , FromLoc   --ML01
                           )
   VALUES (@c_ITrnKey, @c_TranType, @c_StorerKey, @c_SKU, @c_SerialNo, @n_QTY, @c_SourceKey, @c_SourceType
         , @c_Lot, @c_Loc, @c_ToID
         , @c_Lottable01, @c_Lottable02, @c_Lottable03, @d_Lottable04, @d_Lottable05
         , @c_Lottable06, @c_Lottable07, @c_Lottable08, @c_Lottable09, @c_Lottable10
         , @c_Lottable11, @c_Lottable12, @d_Lottable13, @d_Lottable14, @d_Lottable15
         ,'', 0, @c_UCCNo, @c_FromID
         , @c_FromLoc   --ML01
         )
 
   SET @n_err = @@ERROR 
   
   IF @n_err  <> 0
   BEGIN
      SELECT @n_continue = 3
      SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err = 109352
      SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Insert ITrnSerialNo failed (ispITrnSerialNoMove)' + ' ( '
                              + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '
      GOTO QUIT_SP
   END
                                                                             

   Quit_SP:
   IF @n_continue = 3  -- Error Occured - Process And Return  
   BEGIN  
      SET @b_success = 0  
  
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTranCount  
      BEGIN  
         ROLLBACK TRAN  
      END  
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ispITrnSerialNoMove'  
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR      
      RETURN  
   END  
   ELSE  
   BEGIN  
      SET @b_success = 1  
        
      WHILE @@TRANCOUNT > @n_StartTranCount    
      BEGIN    
         COMMIT TRAN    
      END    
      RETURN  
   END   
END -- Create Proc 
GO

GRANT EXECUTE ON [dbo].[ispITrnSerialNoMove] TO NSQL  
GO 
