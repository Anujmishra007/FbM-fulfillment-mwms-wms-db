/************************************************************************/
/* Stored Procedure: lsp_Kit_ExplodeByPackKey_Wrapper                   */
/* Creation Date: 13-DEC-2024                                           */
/* Copyright: MAERSK                                                    */
/* Written by: ngahjuneow                                               */
/*                                                                      */
/* Purpose: LFWM-4807 Kitting item explode by packkey                   */
/*                                                                      */
/* Called By: Kitting                                                   */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 1.0
*/
/* Updates:                                                              */
/* Date         Author   Ver.  Purposes                                  */
/* 15-APR-2025  Ansuman  1.0   UWP-32032 Kitting item explode by Pack Key */
/************************************************************************/

CREATE OR ALTER PROCEDURE [WM].[lsp_Kit_ExplodeByPackKey_Wrapper]
    @c_KitKey NVARCHAR(10) 
   ,@c_KitLineNumber NVARCHAR(5)=''  
   ,@b_Success INT = 1 OUTPUT 
   ,@n_Err INT = 0 OUTPUT
   ,@c_ErrMsg NVARCHAR(250)='' OUTPUT
   ,@c_UserName NVARCHAR(128)=''
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_StartTCnt                  INT  = @@TRANCOUNT
          ,@c_StorerKey                  NVARCHAR(15) = ''
          ,@c_Facility                   NVARCHAR(15) = ''
          ,@c_PackKey                    NVARCHAR(10) = ''
          ,@n_Qty                        INT          = 0
          ,@n_ExpectedQty                INT          = 0
          ,@n_PalletCnt                  INT = 0 
          ,@n_RemainingExpectedQty       INT = 0 
          ,@n_RemainQtyUse               INT = 0 
          ,@n_RemainQty                  INT = 0
          ,@c_LastKitLineNo              NVARCHAR(5) = ''
          ,@c_NextKitLineNo              NVARCHAR(5) = ''
          ,@n_InsertUseQty               INT = 0 
          ,@n_InsertExpectedQty          INT = 0 
          ,@c_GenID                      NVARCHAR(10) =''
          ,@C_GEN_ID_DURING_EXPLODE_PACK NVARCHAR(10) = ''
          ,@c_ToID                       NVARCHAR(10) = ''
          ,@c_IsExploded                 NVARCHAR(1) = 'N'
          ,@c_IsUpdatedID                NVARCHAR(1) = 'N'
   
   SELECT @b_Success = 1, @c_ErrMsg ='', @n_Err = 0

   SET @n_Err = 0 
   IF SUSER_SNAME() <> @c_UserName       
   BEGIN
      EXEC [WM].[lsp_SetUser] @c_UserName = @c_UserName OUTPUT, @n_Err = @n_Err OUTPUT, @c_ErrMsg = @c_ErrMsg OUTPUT
    
      IF @n_Err <> 0 
      BEGIN
         GOTO EXIT_SP
      END
                
      EXECUTE AS LOGIN = @c_UserName        
   END                                   
   
   BEGIN TRAN
    
   BEGIN TRY    
      SELECT @c_Storerkey = Storerkey,
             @c_Facility = Facility
      FROM KIT(NOLOCK)
      WHERE KitKey = @c_Kitkey
    
      IF ISNULL(@c_KitLineNumber,'') <> ''
      BEGIN
         DECLARE CUR_KITDETAIL CURSOR LOCAL FAST_FORWARD READ_ONLY 
         FOR
            SELECT KD.KitLineNumber, KD.ExpectedQty, KD.Qty, KD.Packkey
            FROM KIT K (NOLOCK)
            JOIN KITDETAIL KD (NOLOCK) ON K.Kitkey = KD.Kitkey
            WHERE KD.Kitkey = @c_KitKey
            AND KD.KitLineNumber = @c_KitLineNumber
            AND KD.Type = 'T'
            AND KD.Status <> '9'                        
            AND (KD.ExpectedQty > 0 OR KD.Qty > 0)
      END
      ELSE
      BEGIN
         DECLARE CUR_KITDETAIL CURSOR LOCAL FAST_FORWARD READ_ONLY 
         FOR
            SELECT KD.KitLineNumber, KD.ExpectedQty, KD.Qty, KD.Packkey
            FROM KIT K (NOLOCK)
            JOIN KITDETAIL KD (NOLOCK) ON K.Kitkey = KD.Kitkey
            WHERE KD.Kitkey = @c_KitKey
            AND KD.Type = 'T'
            AND KD.Status <> '9'                        
            AND (KD.ExpectedQty > 0 OR KD.Qty > 0)
      END
    
      OPEN CUR_KITDETAIL
    
      FETCH FROM CUR_KITDETAIL INTO @c_KitLineNumber, @n_ExpectedQty, @n_Qty, @c_PackKey 
    
      WHILE @@FETCH_STATUS = 0
      BEGIN
         SELECT @n_PalletCnt = PACK.Pallet  
         FROM PACK (NOLOCK) 
         WHERE PACK.PackKey = @c_PackKey                                  
       
         IF @n_PalletCnt = 0 
            GOTO FETCH_NEXT
          
         SET @n_RemainingExpectedQty = @n_ExpectedQty   
         SET @n_RemainQtyUse = @n_Qty
       
         IF @n_RemainQtyUse = 0
            SET @n_RemainQty = @n_RemainingExpectedQty 
         ELSE IF @n_RemainQtyUse > @n_RemainingExpectedQty
            SET @n_RemainQty = @n_RemainQtyUse
         ELSE 
            SET @n_RemainQty = @n_RemainingExpectedQty 
          
         IF @n_RemainQty <= @n_PalletCnt
            GOTO FETCH_NEXT

         --remove qty of first pallet at original line
         SET @n_RemainQty = @n_RemainQty - @n_PalletCnt  
         SET @n_RemainingExpectedQty = @n_RemainingExpectedQty - @n_PalletCnt  
         SET @n_RemainQtyUse = @n_RemainQtyUse - @n_PalletCnt                               
       
         IF @n_RemainingExpectedQty < 0
            SET @n_RemainingExpectedQty = 0          

         IF @n_RemainQtyUse < 0
            SET @n_RemainQtyUse = 0          
            
         IF @n_RemainQty > 0
         BEGIN
         	  SET @c_IsExploded = 'Y'
         END    
          
         WHILE @n_RemainQty > 0 
         BEGIN 
            SET @c_LastKitLineNo = ''
              
            SELECT TOP 1 @c_LastKitLineNo = KD.KitLineNumber
            FROM KITDETAIL KD WITH(NOLOCK) 
            WHERE KD.kitKey = @c_KitKey 
            AND KD.Type = 'T'
            ORDER BY KD.KITLineNumber DESC
              
            IF @c_LastKitLineNo = ''
               SET @c_NextkitLineNo = '00001'
            ELSE 
            BEGIN
               IF ISNUMERIC(@c_LastKitLineNo) = 1             
                  SET @c_NextKitLineNo = RIGHT( '0000' + CONVERT(NVARCHAR(5), CAST(@c_LastKitLineNo AS INT) + 1) , 5)
               ELSE 
                  GOTO FETCH_NEXT 
            END                              
              
            If @n_RemainQty - @n_PalletCnt > 0           
            BEGIN
               SET @n_RemainQty = @n_RemainQty - @n_PalletCnt               
               
               IF @n_RemainingExpectedQty >= @n_PalletCnt
                  SET @n_InsertExpectedQty = @n_PalletCnt
               ELSE    
                  SET @n_InsertExpectedQty = @n_RemainingExpectedQty
            
               IF @n_RemainQtyUse >= @n_PalletCnt
                  SET @n_InsertUseQty = @n_PalletCnt
               ELSE    
                  SET @n_InsertUseQty = @n_RemainQtyUse
            END
            ELSE
            BEGIN
               SET @n_RemainQty = 0 
               IF @n_RemainingExpectedQty > 0                                       
                  SET @n_InsertExpectedQty = @n_PalletCnt
               ELSE
                  SET @n_InsertExpectedQty = @n_RemainingExpectedQty
            
               IF @n_RemainQtyUse > 0
                  SET @n_InsertUseQty = @n_PalletCnt
               ELSE                                                                  
                  SET @n_InsertUseQty = @n_RemainQtyUse 
            END
            SET @n_RemainingExpectedQty = @n_RemainingExpectedQty - @n_InsertExpectedQty  
            SET @n_RemainQtyUse = @n_RemainQtyUse - @n_InsertUseQty  
            
            INSERT INTO dbo.KITDETAIL
            (
                KITKey,
                KITLineNumber,
                Type,
                StorerKey,
                Sku,
                Lot,
                Loc,
                Id,
                ExpectedQty,
                Qty,
                PackKey,
                UOM,
                LOTTABLE01,
                LOTTABLE02,
                LOTTABLE03,
                LOTTABLE04,
                LOTTABLE05,
                Status,
                EffectiveDate,
                ExternKitKey,
                ExternLineNo,
                Lottable06,
                Lottable07,
                Lottable08,
                Lottable09,
                Lottable10,
                Lottable11,
                Lottable12,
                Lottable13,
                Lottable14,
                Lottable15,
                Channel,
                Channel_ID
            )
            SELECT KITKey,
                   @c_NextKitLineNo,
                   Type,
                   StorerKey,
                   Sku,
                   Lot,
                   Loc,
                   Id,
                   @n_InsertExpectedQty,
                   @n_InsertUseQty,
                   PackKey,
                   UOM,
                   LOTTABLE01,
                   LOTTABLE02,
                   LOTTABLE03,
                   LOTTABLE04,
                   LOTTABLE05,
                   Status,
                   EffectiveDate,
                   ExternKitKey,
                   ExternLineNo,
                   Lottable06,
                   Lottable07,
                   Lottable08,
                   Lottable09,
                   Lottable10,
                   Lottable11,
                   Lottable12,
                   Lottable13,
                   Lottable14,
                   Lottable15,
                   Channel,
                   Channel_ID
            FROM KITDETAIL(NOLOCK)
            WHERE Kitkey = @c_KitKey
            AND kitLineNumber = @c_KitLineNumber   
            AND Type = 'T'    
           
            -- Update Original Line
            UPDATE KITDETAIL WITH (ROWLOCK) 
            SET   ExpectedQty = ExpectedQty - @n_InsertExpectedQty, 
                  Qty = Qty - @n_InsertUseQty, 
                  EditDate = GETDATE(), 
                  EditWho = @c_UserName 
            WHERE KitKey = @c_Kitkey
            AND   KitLineNumber = @c_kitLineNumber        
            AND   Type = 'T'
         END 
                                    
         FETCH_NEXT:          
                   
         FETCH FROM CUR_KITDETAIL INTO @c_KitLineNumber, @n_ExpectedQty, @n_Qty, @c_PackKey 
      END    
      CLOSE CUR_KITDETAIL
      DEALLOCATE CUR_KITDETAIL         
    
      SELECT @c_GenID = dbo.fnc_GetRight(@c_Facility, @c_Storerkey, '', 'GenID')
    
      IF @c_GenID = '1'
      BEGIN
         SELECT @c_GEN_ID_DURING_EXPLODE_PACK = dbo.fnc_GetRight(@c_Facility, @c_Storerkey, '', 'GEN_ID_DURING_EXPLODE_PACK') --Get from NSQLConfig
       
         IF @c_GEN_ID_DURING_EXPLODE_PACK = '1'
         BEGIN
            DECLARE CUR_KITDETAIL CURSOR LOCAL FAST_FORWARD READ_ONLY FOR 
               SELECT KD.KitLineNumber
               FROM   KITDETAIL KD WITH (NOLOCK) 
               WHERE  KD.KitKey = @c_Kitkey
               AND    KD.Type = 'T'
               AND    ISNULL(KD.ID,'') = ''
               ORDER  BY KD.KitLineNumber                                     
     
            OPEN CUR_KITDETAIL
          
            FETCH FROM CUR_KITDETAIL INTO @c_KitLineNumber
          
            WHILE @@FETCH_STATUS = 0
            BEGIN
            	 SET @c_IsUpdatedID = 'Y'
            	 
               EXEC dbo.nspg_GetKey               
                @KeyName = 'ID'    
               ,@fieldlength = 10
               ,@keystring = @c_ToID OUTPUT    
               ,@b_Success = @b_Success OUTPUT    
               ,@n_err     = @n_err OUTPUT    
               ,@c_errmsg  = @c_errmsg OUTPUT                     

               UPDATE KITDETAIL WITH (ROWLOCK) 
                  SET ID = @c_ToID ,
                     EditDate = GETDATE(), 
                     EditWho = @c_UserName 
               WHERE Kitkey = @c_KitKey
               AND   KitLineNumber = @c_KitLineNumber        
            
               FETCH FROM CUR_KITDETAIL INTO @c_KitLineNumber
            END
            CLOSE CUR_KITDETAIL
            DEALLOCATE CUR_KITDETAIL
         END              
      END
      
      IF @b_Success = 1
      BEGIN
      	 IF @c_IsExploded = 'N' AND @c_IsUpdatedID = 'N'
      	 BEGIN
      	    SET @c_ErrMsg = 'No kit-to is required to explode. (lsp_Kit_ExplodeByPackKey_Wrapper)'  
         END                 
         ELSE IF @c_IsExploded = 'Y' --Y-N  Y-Y
         BEGIN
      	    SET @c_ErrMsg = 'kit-to is exploded sucessfully. (lsp_Kit_ExplodeByPackKey_Wrapper)'  
      	 END
         ELSE  --N-Y
         BEGIN
      	    SET @c_ErrMsg = 'kit-to pallet id updated sucessfully without explode. (lsp_Kit_ExplodeByPackKey_Wrapper)'  
      	 END
      END      
   END TRY  
  
   BEGIN CATCH   
      SET @b_Success = 0                   
      SET @c_ErrMsg = ERROR_MESSAGE()     
      GOTO EXIT_SP  
   END CATCH 
                          
   EXIT_SP: 
    
   IF (XACT_STATE()) = -1
   BEGIN
      SET @b_Success = 0
      ROLLBACK TRAN
   END
   
   IF @b_Success = 0
   BEGIN
      IF @n_StartTCnt = 0 AND @@TRANCOUNT > 0
      BEGIN
         ROLLBACK TRAN
      END

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'lsp_Kit_ExplodeByPackKey_Wrapper'
   END
   ELSE
   IF @b_Success = 1
   BEGIN
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END

   WHILE @@TRANCOUNT < @n_StartTCnt
   BEGIN
      BEGIN TRAN
   END
       
   REVERT
END
GO
GRANT EXECUTE ON [WM].[lsp_Kit_ExplodeByPackKey_Wrapper] TO nSQL 
GO
