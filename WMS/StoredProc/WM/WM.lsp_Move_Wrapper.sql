SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/  
/* Stored Procedure: lsp_Move_Wrapper                                   */  
/* Creation Date: 15-Mar-2018                                           */  
/* Copyright: Maersk                                                    */  
/* Written by:                                                          */  
/*                                                                      */  
/* Purpose: Inventory Move                                              */  
/*                                                                      */  
/* Called By: Inventory Move / TM Inventory Move                        */  
/*                                                                      */  
/* PVCS Version: 1.4                                                    */  
/*                                                                      */  
/* Version: 8.0                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date        Author   Ver   Purposes                                  */ 
/* 2020-10-13  Wan01    1.1   Fixed.                                    */
/* 2020-11-26  Wan02    1.1   Add Big Outer Begin Try..End Try to enable*/
/*                            Revert when Sub SP Raise error            */
/* 2020-12-08  Wan03    1.1   LFWM-2440 - UAT Philippines PH SCE Inventory*/
/*                            Move using ToUOM Not Functional           */
/* 2023-11-21  NJOW01   1.2   JSM-192497 -Include movemethod for TM Move*/
/* 2023-11-21  NJOW01   1.2   DEVOPS Combine Script                     */
/* 2024-04-23  Wan04    1.3   LFWM-4161 - TM Inventory Move Error       */
/* 2024-06-18  Wan05    1.4   LFWM-4607 - RG UATPROD-All storer-Print Label*/
/*                            button is not responding in Inventory Move*/
/*                            module                                    */
/* 2025-10-06  Michael  1.5   UWP-42038 - Inventory Moves not executed  */
/*                            StorerCfg CheckNonCommingleSKUInMove On   */
/*                            and move to non-CommingleSku loc (ML01)   */
/* 2025-05-26  SWT01    1.6   Setting Session Context for user name     */
/* 2025-10-10  SPC040   1.7   Replace SUSER_SNAME with fnc_GetUserName  */
/* 2025-10-20  Michael  1.8   FCR-8378 - Add StorerConfig               */
/*                            SerialNoUpdateLotLocID (ML02)             */
/************************************************************************/    
CREATE OR ALTER PROCEDURE [WM].[lsp_Move_Wrapper]
   @c_Storerkey            NVARCHAR(15) 
  ,@c_Sku                  NVARCHAR(20)
  ,@c_Lot                  NVARCHAR(10)
  ,@c_Loc                  NVARCHAR(10)
  ,@c_Id                   NVARCHAR(18)
  ,@c_ToLoc                NVARCHAR(10)
  ,@c_ToID                 NVARCHAR(18)
  ,@n_ToQty                INT
  ,@c_ToPackkey            NVARCHAR(10) = ''    --If TM Move optional
  ,@c_ToUom                NVARCHAR(10) = ''    --If TM Move optional
  ,@c_TaskManagerMove      CHAR(1)      = 'N'
  ,@b_Success              INT = 1           OUTPUT
  ,@n_Err                  INT = 0           OUTPUT
  ,@c_ErrMsg               NVARCHAR(250)=''  OUTPUT
  ,@n_WarningNo            INT = 0           OUTPUT
  ,@c_ProceedWithWarning   CHAR(1)      = 'N' 
  ,@c_UserName             NVARCHAR(128)= ''
  ,@c_MoveMethod           NVARCHAR(10) = ''                                              --(Wan04)
  ,@c_Movekey              NVARCHAR(10) = '' OUTPUT                                       --(Wan05)                 
  AS
BEGIN 
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
    
   SET @n_Err = 0 
   -- (SWT01) - START
   DECLARE @b_ExecuteAs BIT = 0
   IF SUSER_SNAME() <> @c_UserName
   BEGIN 
      EXEC [WM].[lsp_SetUser] 
            @c_UserName = @c_UserName  OUTPUT
         ,  @n_Err      = @n_Err       OUTPUT
         ,  @c_ErrMsg   = @c_ErrMsg    OUTPUT
         ,  @b_ExecuteAs = @b_ExecuteAs OUTPUT
         
      IF @n_Err <> 0 
      BEGIN
         GOTO EXIT_SP
      END

      IF @b_ExecuteAs = 1                    
         EXECUTE AS LOGIN = @c_UserName
   END
   -- (SWT01) - END

   --(Wan01) - START
   BEGIN TRY   
      DECLARE @n_Continue                    INT
            ,@n_starttcnt                    INT    
            ,@c_itrnkey                      NVARCHAR(10) 
            ,@c_PrintMoveLabel               NVARCHAR(10)                           --(Wan05)                  
            ,@c_Facility                     NVARCHAR(5)
            --,@c_Movekey                    NVARCHAR(10)                           --(Wan05) 
            ,@c_CheckNonCommingleSKUInMove   NVARCHAR(10)
            --,@c_MoveMethod                 NVARCHAR(10)=''                        --(Wan04)--NJOW01
            ,@c_Sourcekey                    NVARCHAR(20)=''                        --(Wan05) 
            ,@c_SourceType                   NVARCHAR(30)='lsp_Move_Wrapper'        --(Wan05)              
            ,@c_SerialNoUpdateLotLocID       NVARCHAR(30) = ''   --ML02
            ,@c_SerialNoCapture              NVARCHAR(1)  = ''   --ML02
            ,@n_Qty_ID                       INT                 --ML02

      SELECT @n_starttcnt=@@TRANCOUNT, @n_err=0, @b_success=1, @c_errmsg='', @n_continue=1

      SELECT @c_Facility = Facility                                                 --(Wan05) - START
      FROM LOC (NOLOCK)
      WHERE Loc = @c_Loc                                                            --(Wan05) - END

      IF @n_continue IN(1,2) AND (@c_ProceedWithWarning <> 'Y' OR @n_WarningNo < 1)
      BEGIN
         SELECT @c_CheckNonCommingleSKUInMove = dbo.fnc_GetRight(@c_Facility, @c_Storerkey, '', 'CheckNonCommingleSKUInMove')
       
         IF @c_CheckNonCommingleSKUInMove = '1'
         BEGIN
            IF EXISTS(SELECT 1
                        FROM LOC (NOLOCK)
                        WHERE Loc = @c_ToLoc
                        AND CommingleSku = '0')
            BEGIN
--ML01               IF EXISTS(SELECT COUNT(DISTINCT SKU)
               IF EXISTS(SELECT TOP 1 1   --ML01
                        FROM SKUXLOC (NOLOCK)
                        WHERE SKU <> @c_Sku
                        AND Loc = @c_ToLoc
                        AND Qty > 0)                  
               BEGIN
--ML01                  SELECT @n_WarningNo = 1
--ML01                  SELECT @n_continue = 4                                            --(Wan05)
--ML01                  SELECT @c_errmsg = 'Move Sku To Non Commingle Location ?'
--ML01-S
                  SET @n_Continue = 3
                  SET @n_err = 552704
                  SET @c_errmsg = 'NSQL' +CONVERT(CHAR(6),@n_err) + ': Not Allow to move commingle sku To Location: '+ISNULL(TRIM(@c_ToLoc),'')+'. (lsp_Move_Wrapper)'
--ML01-E
               END                                           
            END
          END 
       END

      --ML02-S
      IF @n_continue IN(1,2)
      BEGIN
         SELECT @c_SerialNoUpdateLotLocID = dbo.fnc_GetRight(@c_Facility, @c_Storerkey, '', 'SerialNoUpdateLotLocID')

         SET @c_SerialNoCapture = ''
         SELECT @c_SerialNoCapture = SerialNoCapture
         FROM SKU (NOLOCK)
         WHERE Storerkey = @c_Storerkey AND Sku = @c_Sku

         IF @c_SerialNoUpdateLotLocID = '1' AND @c_SerialNoCapture IN ('1', '2')
         BEGIN
            SET @n_Qty_ID = 0
            SELECT @n_Qty_ID = ISNULL(SUM(Qty),0)
              FROM LOTxLOCxID (NOLOCK)
             WHERE Storerkey = @c_Storerkey
               AND Loc       = @c_Loc
               AND ID        = @c_ID

            IF NOT (ISNULL(@n_ToQty,0)>0 AND ISNULL(@n_ToQty,0)=ISNULL(@n_Qty_ID,0))
            BEGIN
               SET @n_Continue = 3
               SET @n_err = 552705
               SET @c_errmsg = 'NSQL' +CONVERT(CHAR(6),@n_err) + ': Partial ID Movment is not allowed when SerialNoUpdateLotLocID turns on and SerialNoCapture=1,2. (lsp_Move_Wrapper)'
            END
         END
      END
      --ML02-E
    
       IF @n_continue IN(1,2) AND @c_TaskManagerMove = 'Y' 
       BEGIN
         IF ISNULL(@c_ToID,'') = ''
            SET @c_ToID = @c_ID 
         
         IF @c_MoveMethod IN ('', NULL)                                             --(Wan04) - START
         BEGIN
            --NJOW01 S   
            IF EXISTS(SELECT 1 
                      FROM LOTXLOCXID LLI (NOLOCK) 
                      WHERE LLI.qty > 0 
                      AND LLI.ID <> ''
                      AND LLI.Storerkey = @c_Storerkey
                      AND LLI.ID = @c_ID
                      AND LLI.Loc = @c_Loc
                      HAVING SUM(LLI.Qty) = @n_ToQty)
            BEGIN
               SET @c_MoveMethod = 'FP'
            END
            ELSE 
            BEGIN
               SET @c_MoveMethod = 'PP'
            END
            --NJOW01 E 
         END                                                                        --(Wan04) - END

         IF @c_sku = 'MIXED_SKU'
            SET @c_sku = ''
         BEGIN TRY          
            EXEC dbo.isp_TaskManagerMove 
                  @c_storerkey   = @c_Storerkey  
               ,  @c_sku         = @c_Sku 
               ,  @c_Lot         = @c_Lot                                           --(Wan04) 
               ,  @c_fromloc     = @c_Loc  
               ,  @c_fromid      = @c_ID  
               ,  @c_toloc       = @c_ToLoc 
               ,  @c_toid        = @c_ToId  
               ,  @n_qty         = @n_ToQty  
               ,  @b_Success     = @b_Success   OUTPUT 
               ,  @n_err         = @n_err       OUTPUT  
               ,  @c_errmsg      = @c_errmsg    OUTPUT 
               ,  @c_MoveMethod  = @c_MoveMethod --NJOW01                  
         END TRY

         BEGIN CATCH
            SET @n_Continue = 3
            SET @n_err = 552701
            SET @c_ErrMsg = ERROR_MESSAGE()
            SET @c_errmsg = 'NSQL' +CONVERT(CHAR(6),@n_err) + ': Error Executing isp_TaskManagerMove. (lsp_Move_Wrapper)'
                           + '( ' + @c_errmsg + ' )'

            IF (XACT_STATE()) = -1     --(Wan01) - START
            BEGIN
               IF @@TRANCOUNT > 0 
               BEGIN
                  ROLLBACK TRAN
               END
            END                        --(Wan01) - END
         END CATCH    
                   
         IF @b_success = 0 OR @n_Err <> 0        
         BEGIN        
            SET @n_continue = 3      
            GOTO EXIT_SP
         END           
      END   

      IF @n_continue IN(1,2) AND @c_TaskManagerMove <> 'Y' 
      BEGIN 
         SET @c_SourceKey = ''                                                      --(Wan05) - START

         SELECT @c_PrintMoveLabel = dbo.fnc_GetRight(@c_Facility, @c_Storerkey, '', 'PRINTMOVELABEL')

         IF @c_PrintMoveLabel = '1'
         BEGIN
            IF @c_Movekey = ''
            BEGIN
               EXEC dbo.nspg_GetKey               
                    @KeyName = 'MOVEKEY'    
                  , @fieldlength = 10
                  , @keystring = @c_Movekey OUTPUT  
                  , @b_Success = @b_Success OUTPUT    
                  , @n_err     = @n_err     OUTPUT                              
                  , @c_errmsg  = @c_errmsg  OUTPUT
                  , @n_batch  = 1 
            END 
            SET @c_SourceKey = @c_Movekey
         END                                                                        --(Wan05) - END                                                                
                                                                       
         --(Wan03) - START             
         --IF ISNULL(@c_ToPackkey,'') = ''
         --BEGIN
         --   SELECT @c_ToPackkey = PACK.Packkey,
         --         @c_ToUOM = PACK.PackUOM3
         --   FROM SKU (NOLOCK)
         --   JOIN PACK (NOLOCK) ON SKU.Packkey = PACK.Packkey
         --   WHERE SKU.Storerkey = @c_Storerkey
         --   AND SKU.Sku = @c_Sku
         --END
         --(Wan03) - END

         BEGIN TRY         
            EXEC dbo.nspItrnAddMove
            @n_itrnsysid      = NULL ,
            @c_storerkey      = @c_storerkey,
            @c_sku            = @c_Sku,
            @c_lot            = @c_Lot,
            @c_fromid         = @c_ID,
            @c_fromloc        = @c_Loc ,
            @c_toloc          = @c_Toloc,
            @c_toid           = @c_ToID,
            @c_status         = '',
            @c_lottable01     = '', 
            @c_lottable02     = '', 
            @c_lottable03     = '', 
            @d_lottable04     = NULL, 
            @d_lottable05     = NULL, 
            @c_lottable06     = '',
            @c_lottable07     = '',
            @c_lottable08     = '',
            @c_lottable09     = '',
            @c_lottable10     = '',
            @c_lottable11     = '',
            @c_lottable12     = '',
            @d_lottable13     = NULL,
            @d_lottable14     = NULL,
            @d_lottable15     = NULL,
            @n_casecnt        = 0 ,
            @n_innerpack      = 0 ,
            @n_qty            = @n_ToQty ,
            @n_pallet         = 0 ,
            @f_cube           = 0 ,
            @f_grosswgt       = 0 ,
            @f_netwgt         = 0 ,
            @f_otherunit1     = 0 ,
            @f_otherunit2     = 0 ,
            @c_sourcetype     = @c_Sourcetype,                                      --(Wan05)
            @c_sourcekey      = @c_SourceKey,                                       --(Wan05)
            @c_packkey        = @c_ToPackkey,
            @c_uom            = @c_ToUom ,
            @b_uomcalc        = 1 ,
            @d_effectivedate  = NULL,
            @c_itrnkey        = @c_itrnkey OUTPUT,
            @b_success        = @b_success OUTPUT,
            @n_err            = @n_err OUTPUT,
            @c_errmsg         = @c_errmsg OUTPUT,
            @c_MoveRefKey     = ''    
         END TRY
         BEGIN CATCH
            SET @n_Continue = 3
            SET @n_err = 552702
            SET @c_ErrMsg = ERROR_MESSAGE()
            SET @c_errmsg = 'NSQL' +CONVERT(CHAR(6),@n_err) + ': Error Executing nspItrnAddMove. (lsp_Move_Wrapper)'
                           + '( ' + @c_errmsg + ' )'

            IF (XACT_STATE()) = -1     --(Wan01) - START
            BEGIN
               IF @@TRANCOUNT > 0 
               BEGIN
                  ROLLBACK TRAN
               END
            END                        --(Wan01) - END
         END CATCH    
         IF @b_success = 0 OR @n_Err <> 0        
         BEGIN  
            SET @n_continue = 3      
            GOTO EXIT_SP
         END                     
      END   
       /*
       IF @n_continue IN(1,2)
       BEGIN
          SELECT @PrintMoveLabel = dbo.fnc_GetRight(@c_Facility, @c_Storerkey, '', 'PRINTMOVELABEL')

          IF @PrintMoveLabel = '1'
          BEGIN
             EXEC dbo.nspg_GetKey               
                @KeyName = 'MOVEKEY'    
               ,@fieldlength = 10
               ,@keystring = @c_Movekey OUTPUT  
               ,@c_Movekey OUTPUT    
               ,@b_Success OUTPUT    
               ,@n_err     OUTPUT                              
               ,@c_errmsg  OUTPUT    

             INSERT INTO TempMoveSKU (Movekey, StorerKey, Sku, Lot, FromID,   FromLoc, ToLoc, Qty, ToID)                             
             VALUES (@c_Movekey, @c_Storerkey, @c_Sku, @c_Lot, @c_ID, @c_Loc, @c_ToLoc, @n_ToQty, @c_ToID)              
       
             SET @n_err =  @@ERROR 
          
             IF @n_err <> 0
             BEGIN
                SELECT @n_continue = 3  
                    SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 552703   
                    SELECT @c_errmsg='NSQL'+CONVERT(char(6),@n_err)+': Insert Table TempMoveSKU Failed. (lsp_Move_Wrapper)' + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) ' 
             END
             ELSE
             BEGIN                     
                
                UPDATE TempMoveSKU
                SET MoveKey = @c_Movekey  
                WHERE AddWho = dbo.fnc_GetUserName()
                AND ISNULL(Movekey,'')=''
             END                                               
          END
       END
       */
   END TRY

   BEGIN CATCH
      SET @n_continue = 3
      SET @c_ErrMsg = 'Stock Move fail. (lsp_Move_Wrapper) ( SQLSvr MESSAGE=' + ERROR_MESSAGE() + ' ) '
      GOTO EXIT_SP
   END CATCH
   --(Wan02) - END             
           
   EXIT_SP: 

   IF @n_continue=3  -- Error Occured - Process And Return  
   BEGIN  
      SELECT @b_success = 0  
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_starttcnt  
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
       
      IF @n_WarningNo = 0
      BEGIN
         execute nsp_logerror @n_err, @c_errmsg, 'lsp_Move_Wrapper'  
         --RAISERROR (@c_errmsg, 16, 1) WITH SETERROR
      END
      --RETURN  
   END  
   ELSE  
   BEGIN  
      SELECT @n_WarningNo = 0
      SELECT @b_success = 1  
      WHILE @@TRANCOUNT > @n_starttcnt  
      BEGIN  
         COMMIT TRAN  
      END  
      --RETURN  
   END  

   WHILE @@TRANCOUNT < @n_StartTCnt -- (Wan01) - START
   BEGIN
      BEGIN TRAN
   END                              -- (Wan01) - END  

   IF @b_ExecuteAs = 1              -- (SWT01)
      REVERT                        -- (Wan02) - Move down

   EXEC [WM].[lsp_ResetUser]  -- (SWT01)
END
GO
GRANT EXECUTE ON [WM].[lsp_Move_Wrapper] TO nSQL 
GO
