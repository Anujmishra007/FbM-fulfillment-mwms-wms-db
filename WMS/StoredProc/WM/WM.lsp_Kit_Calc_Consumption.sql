
IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[WM].[lsp_Kit_Calc_Consumption]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
   DROP PROCEDURE [WM].[lsp_Kit_Calc_Consumption]
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

/*************************************************************************/  
/* Stored Procedure: lsp_Kit_Calc_Consumption                            */  
/* Creation Date: 28-FEB-2018                                            */  
/* Copyright: LFL                                                        */  
/* Written by:                                                           */  
/*                                                                       */  
/* Purpose:                                                              */  
/*                                                                       */  
/* Called By:                                                            */  
/*                                                                       */  
/*                                                                       */  
/* Version: 1.2                                                          */  
/*                                                                       */  
/* Data Modifications:                                                   */  
/*                                                                       */  
/* Updates:                                                              */  
/* Date        Author   Ver   Purposes                                   */ 
/* 28-Dec-2020 SWT01    1.0   Adding Begin Try/Catch                     */
/* 15-Jan-2021 Wan01    1.1   Execute Login if @c_UserName<>SUSER_SNAME()*/
/* 07-Dec-2021 Chai01   1.2   LFWM-3094 - Change Data type for           */
/*                            @n_ComponentQty, @n_ParentQty,             */
/*                            @n_FromCompleteQty and @n_ToCompleteQty    */
/*                            from INT to DECIMAL                        */
/* 07-Dec-2021 Chai01   1.2   DevOps Combine Script                      */
/* 10-Dec-2021 Chai02   1.3   LFWM-3166 - UAT - TW | Kitting To Part UOM Issue*/
/* 10-Dec-2021 Chai02   1.3   DevOps Combine Script                      */
/*************************************************************************/   
CREATE PROCEDURE [WM].[lsp_Kit_Calc_Consumption]  (
   @c_StorerKey      NVARCHAR(15), 
   @c_KitKey         NVARCHAR(10),
   @c_KitLineNumber  NVARCHAR(5),
   @c_Type           NVARCHAR(5), 
   @c_DeletePrevious CHAR(1) = 'Y',
   @b_Success        int = 1 OUTPUT,
   @n_Err            int = 0 OUTPUT,
   @c_Errmsg         NVARCHAR(250) = '' OUTPUT,
   @c_UserName       NVARCHAR(128)  = '' )
AS  
BEGIN  
   SET ANSI_NULLS ON
   SET ANSI_PADDING ON
   SET ANSI_WARNINGS ON
   SET QUOTED_IDENTIFIER ON
   SET CONCAT_NULL_YIELDS_NULL ON
   SET ARITHABORT ON

   DECLARE @n_Continue     INT = '1'         
         , @n_Count        INT = 0 
         , @c_ComponentSku NVARCHAR(20) = '' 
         , @n_ComponentQty DECIMAL = 0 --(Chai01)
         , @n_ParentQty    DECIMAL = 0 --(Chai01) 
         , @n_Remainder    INT = 0
         , @n_BOMQty       INT = 0  
         , @c_NewKitLineNo NVARCHAR(5)  = ''
         , @c_PackKey      NVARCHAR(10) = ''
         , @c_UOM          NVARCHAR(10) = ''
         
   SET @b_Success = 1
   SET @c_ErrMsg = ''

   SET @n_Err = 0
   IF SUSER_SNAME() <> @c_UserName       --(Wan01) - START
   BEGIN    
      EXEC [WM].[lsp_SetUser] 
               @c_UserName = @c_UserName  OUTPUT
            ,  @n_Err      = @n_Err       OUTPUT
            ,  @c_ErrMsg   = @c_ErrMsg    OUTPUT
                
      IF @n_Err <> 0 
      BEGIN
         GOTO EXIT_SP
      END

      EXECUTE AS LOGIN = @c_UserName
   END                                   --(Wan01) - END
   
   BEGIN TRY -- SWT01 - Begin Outer Begin Try
   
      DECLARE @c_FromSKU         NVARCHAR(20) = '',
              @c_ToSKU           NVARCHAR(20) = '',  
              @n_FromExpectedQty INT = 0,
              @n_FromCompleteQty DECIMAL = 0, --(Chai01)
              @n_ToExpectedQty   INT = 0,
              @n_ToCompleteQty   DECIMAL = 0, --(Chai01)
              @n_ToUOM           NVARCHAR(10) = '', --(Chai02)
              @n_ToPackKey       NVARCHAR(10) = '', --(Chai02)
              @n_ToBOMQty        INT = 0 --(Chai02)
              
      SELECT @c_StorerKey = KD.StorerKey, 
             @c_ToSKU   = KD.Sku,
             @n_ToExpectedQty = KD.ExpectedQty,
             @n_ToCompleteQty = KD.Qty,
             @n_ToUOM = KD.UOM, --(Chai02)
             @n_ToPackKey = KD.PackKey --(Chai02) 
      FROM KITDETAIL AS KD WITH (NOLOCK)
      WHERE KD.KITKey = @c_KitKey 
      AND   KD.KITLineNumber = @c_KitLineNumber 
      AND   KD.[Type] = 'T'
   
      IF ISNULL(RTRIM(@c_ToSKU),'') = ''
      BEGIN
         SET @n_continue = 3  
         SET @n_Err = 552201 
         SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(6), @n_Err) + 
               ': SKU Cannot be BLANK (lsp_Kit_Gen_Components)'               
         GOTO EXIT_SP   
      END

      --START(Chai02)
      IF ISNULL(RTRIM(@n_ToUOM),'') = ''
      BEGIN
         SET @n_continue =3
         SET @n_err = 552206
         SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(6), @n_Err) + 
               ': UOM Cannot be BLANK (lsp_Kit_Gen_Components)'
         GOTO EXIT_SP
      END

      IF ISNULL(RTRIM(@n_ToPackKey),'') = ''
      BEGIN
         SET @n_continue =3
         SET @n_err = 552207
         SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(6), @n_Err) + 
               ': Pack Key Cannot be BLANK (lsp_Kit_Gen_Components)'
         GOTO EXIT_SP
      END
      --END(Chai02)
   
      IF @n_ToCompleteQty <= 0 
      BEGIN
         SET @n_continue = 3  
         SET @n_Err = 552202 
         SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(6), @n_Err) + 
               ': Completed Qty Cannot Be Blank (lsp_Kit_Gen_Components)'                 
         GOTO EXIT_SP      
      END
   
      IF NOT EXISTS (SELECT 1 FROM KITDETAIL AS k WITH(NOLOCK)
                     WHERE k.KITKey = @c_KitKey 
                     AND   k.[Type] = 'F' )
      BEGIN
         SET @n_continue = 3  
         SET @n_Err = 552203 
         SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(6), @n_Err) + 
               ': From Components record not found (lsp_Kit_Gen_Components)'                 
         GOTO EXIT_SP      
      END
   
   
      DECLARE CUR_SOURCE_KITDETAIL CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT KITLineNumber, Sku, ExpectedQty, PackKey
      FROM KITDETAIL WITH (NOLOCK)
      WHERE KITKey = @c_KitKey 
      AND   [Type] = 'F'
      AND   [Status] <> '9'
   
      OPEN CUR_SOURCE_KITDETAIL
   
      FETCH FROM CUR_SOURCE_KITDETAIL INTO @c_KitLineNumber, @c_FromSKU, @n_FromExpectedQty, @c_PackKey
   
      WHILE @@FETCH_STATUS = 0
      BEGIN
         SET @n_ComponentQty = 0 
         SET @n_ParentQty = 0 
      
         SELECT @n_ComponentQty = Qty, 
                @n_ParentQty = ParentQty
         FROM BillOfMaterial WITH (NOLOCK)
         WHERE Storerkey = @c_StorerKey 
         AND   Sku = @c_ToSKU
         AND   ComponentSku = @c_FromSKU 

         IF @n_ComponentQty = 0 OR @n_ParentQty = 0 
         BEGIN
            SET @n_continue = 3  
            SET @n_Err = 552204 
            SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(6), @n_Err) + 
                  ': Component Qty or Parent Qty is ZERO (lsp_Kit_Gen_Components)'                 
            GOTO EXIT_SP         
         END

         --START(Chai02)
         SET @n_ToBOMQty = (SELECT CASE @n_ToUOM 
            WHEN PACK.PACKUOM1 THEN PACK.CaseCnt 
				WHEN PACK.PACKUOM2 THEN PACK.InnerPack  
            WHEN PACK.PACKUOM3 THEN 1
				WHEN PACK.PACKUOM4 THEN PACK.Pallet WHEN PACK.PACKUOM5 THEN PACK.Cube
				WHEN PACK.PACKUOM6 THEN PACK.GrossWgt WHEN PACK.PACKUOM7 THEN PACK.NetWgt
				WHEN PACK.PACKUOM8 THEN PACK.OtherUnit1 WHEN PACK.PACKUOM9 THEN PACK.OtherUnit2
				END UOMQty 
         FROM PACK WITH (NOLOCK) WHERE PACK.PackKey = @n_ToPackKey)
         --END(Chai02)

         SET @n_FromCompleteQty = (@n_ToCompleteQty*@n_ToBOMQty/@n_ParentQty) * @n_ComponentQty --(Chai02)
      
         IF ( (@n_ToCompleteQty * @n_FromExpectedQty) % @n_ToExpectedQty) > 0
         BEGIN
            SET @n_continue = 3  
            SET @n_Err = 552205 
            SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(6), @n_Err) + 
                  ': Remaining QTY found for Component Sku! Please Check UOM Setup (lsp_Kit_Gen_Components)'               
            GOTO EXIT_SP  
         END
      
         UPDATE KITDETAIL WITH (ROWLOCK)
            SET Qty = @n_FromCompleteQty, EditDate = GETDATE(), EditWho = SUSER_SNAME()
         WHERE KITKey = @c_KitKey 
         AND   KITLineNumber = @c_KitLineNumber 
         AND   [Type] = 'F' 
         AND   [Status] <> '9'
      
         FETCH FROM CUR_SOURCE_KITDETAIL INTO @c_KitLineNumber, @c_FromSKU, @n_FromExpectedQty, @c_PackKey
      END
   
      CLOSE CUR_SOURCE_KITDETAIL
      DEALLOCATE CUR_SOURCE_KITDETAIL

   END TRY  
  
   BEGIN CATCH 
      SET @n_Continue = 3 
      SET @c_Errmsg = ERROR_MESSAGE()     
      GOTO EXIT_SP  
   END CATCH -- (SWT01) - End Big Outer Begin try.. end Try Begin Catch.. End Catch
   
   EXIT_SP:
   
   IF @n_Continue = 3   
   BEGIN
      SET @b_Success = 0
   END
   ELSE
   BEGIN
      SET @b_Success = 1
   END
   REVERT      
END  
GO
GRANT EXECUTE ON [WM].[lsp_Kit_Calc_Consumption] TO nSQL 
GO


