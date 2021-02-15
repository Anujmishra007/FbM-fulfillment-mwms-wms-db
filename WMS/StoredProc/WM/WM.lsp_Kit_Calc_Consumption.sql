
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
/* Version: 1.1                                                          */  
/*                                                                       */  
/* Data Modifications:                                                   */  
/*                                                                       */  
/* Updates:                                                              */  
/* Date        Author   Ver   Purposes                                   */ 
/* 28-Dec-2020 SWT01    1.0   Adding Begin Try/Catch                     */
/* 15-Jan-2021 Wan01    1.1   Execute Login if @c_UserName<>SUSER_SNAME()*/
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
         , @n_ComponentQty INT = 0 
         , @n_ParentQty    INT = 0 
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
              @n_FromCompleteQty INT = 0,
              @n_ToExpectedQty   INT = 0,
              @n_ToCompleteQty   INT = 0
              
      SELECT @c_StorerKey = KD.StorerKey, 
             @c_ToSKU   = KD.Sku,
             @n_ToExpectedQty = KD.ExpectedQty,
             @n_ToCompleteQty = KD.Qty 
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
      
         SET @n_FromCompleteQty = (@n_ToCompleteQty/@n_ParentQty) * @n_ComponentQty
      
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


