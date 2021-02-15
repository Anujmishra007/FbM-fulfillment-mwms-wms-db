IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[WM].[lsp_Kit_Calc_Consumption_BOM]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
   DROP PROCEDURE [WM].[lsp_Kit_Calc_Consumption_BOM]
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

/*************************************************************************/  
/* Stored Procedure: lsp_Kit_Calc_Consumption_BOM                        */  
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
CREATE PROCEDURE [WM].[lsp_Kit_Calc_Consumption_BOM]  (
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
      EXEC [WM].[lsp_SetUser] @c_UserName = @c_UserName OUTPUT, @n_Err = @n_Err OUTPUT, @c_ErrMsg = @c_ErrMsg OUTPUT
   
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
              @n_ToCompleteQty   INT = 0,
              @n_RemainingQty    INT = 0,
              @n_ShortQty        INT = 0 
              
      SELECT @c_StorerKey = KD.StorerKey, 
             @c_FromSKU   = KD.Sku,
             @n_FromExpectedQty = KD.ExpectedQty,
             @n_FromCompleteQty = KD.Qty 
      FROM KITDETAIL AS KD WITH (NOLOCK)
      WHERE KD.KITKey = @c_KitKey 
      AND   KD.KITLineNumber = @c_KitLineNumber 
      AND   KD.[Type] = 'F'
   
      IF ISNULL(RTRIM(@c_FromSKU),'') = ''
      BEGIN
         SET @n_continue = 3  
         SET @n_Err = 552451 
         SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(5), @n_Err) + 
               ': SKU Cannot be BLANK (lsp_Kit_Calc_Consumption_BOM)'               
         GOTO EXIT_SP   
      END
   
      IF @n_FromCompleteQty <= 0 
      BEGIN
         SET @n_continue = 3  
         SET @n_Err = 552452 
         SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(5), @n_Err) + 
               ': Completed Qty Cannot Be Blank (lsp_Kit_Calc_Consumption_BOM)'                 
         GOTO EXIT_SP      
      END
   
      IF NOT EXISTS (SELECT 1 FROM KITDETAIL AS k WITH(NOLOCK)
                     WHERE k.KITKey = @c_KitKey 
                     AND   k.[Type] = 'T' 
                     AND   k.[Status] <> '9' )
      BEGIN
         SET @n_continue = 3  
         SET @n_Err = 552453 
         SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(5), @n_Err) + 
               ': To Components record not found (lsp_Kit_Calc_Consumption_BOM)'                
         GOTO EXIT_SP      
      END
   
      IF OBJECT_ID('tempdb..#KIT_BOM_DETAIL') IS NOT NULL 
      BEGIN
         DROP TABLE #KIT_BOM_DETAIL
      END
   
      CREATE TABLE #KIT_BOM_DETAIL (
         KitKey        NVARCHAR(10),
         KitLineNumber NVARCHAR(5), 
         [Type]        NVARCHAR(5), 
         Qty           INT )
         
      DECLARE CUR_COMPONENTS CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT ComponentSku, Qty 
      FROM BillOfMaterial WITH (NOLOCK)
      WHERE Storerkey = @c_StorerKey 
      AND   Sku = @c_ToSKU
   
      OPEN CUR_COMPONENTS
   
      FETCH FROM CUR_COMPONENTS INTO @c_ComponentSku, @n_ComponentQty 
                                                  
      WHILE @@FETCH_STATUS = 0
      BEGIN   
         SET @n_RemainingQty = @n_ComponentQty * @n_FromCompleteQty
         SET @n_ShortQty = 0 
      
         DECLARE CUR_SOURCE_KITDETAIL CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT KITLineNumber, ExpectedQty 
         FROM KITDETAIL WITH (NOLOCK)
         WHERE KITKey = @c_KitKey 
         AND   [Type] = 'T'
         AND   [Status] <> '9' 
         AND   Sku = @c_ComponentSku 
   
         OPEN CUR_SOURCE_KITDETAIL
   
         FETCH FROM CUR_SOURCE_KITDETAIL INTO @c_KitLineNumber, @n_ToExpectedQty
   
         WHILE @@FETCH_STATUS = 0 
         BEGIN         
            IF @n_RemainingQty=0
               SET @n_ToCompleteQty = @n_ToExpectedQty 
            ELSE 
            IF (@n_RemainingQty < 0) AND (@n_ToExpectedQty > @n_RemainingQty)
            BEGIN
                SET @n_ShortQty = @n_ToExpectedQty + @n_RemainingQty  
                SET @n_ToCompleteQty = @n_ShortQty
            END
            ELSE 
            IF @n_RemainingQty > 0
            BEGIN
                IF @n_RemainingQty >= @n_ToExpectedQty
                   SET @n_ToCompleteQty = @n_ToExpectedQty
                ELSE 
                IF @n_RemainingQty < @n_ToExpectedQty
                BEGIN
                   SET @n_ToCompleteQty = @n_RemainingQty
                END
            END
 
            SET @n_RemainingQty = @n_RemainingQty - @n_ToCompleteQty
               
            INSERT INTO #KIT_BOM_DETAIL
            (  KitKey, KitLineNumber, [Type], Qty )
            VALUES
            (
               @c_KitKey,
               @c_KitLineNumber,
               'T',
               @n_ToCompleteQty
            )
            
            FETCH FROM CUR_SOURCE_KITDETAIL INTO @c_KitLineNumber, @n_ToExpectedQty 
         END   
         CLOSE CUR_SOURCE_KITDETAIL
         DEALLOCATE CUR_SOURCE_KITDETAIL
      
         IF EXISTS(SELECT 1 FROM #KIT_BOM_DETAIL AS kbd WITH(NOLOCK)
                   WHERE kbd.Qty < 0 )
         BEGIN
            SET @n_continue = 3  
            SET @n_Err = 552454 
            SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(5), @n_Err) + 
                  ': Insufficient Qty for Component SKU (lsp_Kit_Calc_Consumption_BOM)'               
            GOTO EXIT_SP         
         END
         ELSE 
         BEGIN
            UPDATE KITDETAIL WITH (ROWLOCK)
               SET Qty = kbd.Qty, EditDate = GETDATE(), EditWho = SUSER_SNAME() 
            FROM KITDETAIL 
            JOIN #KIT_BOM_DETAIL AS kbd WITH(NOLOCK) ON kbd.KITKey = KITDETAIL.KITKey 
                  AND kbd.KITLineNumber = KITDETAIL.KITLineNumber 
                  AND kbd.[Type] = KITDETAIL.[Type]
               
         END
      
         FETCH FROM CUR_COMPONENTS INTO @c_ComponentSku, @n_ComponentQty 
      END
   
      CLOSE CUR_COMPONENTS
      DEALLOCATE CUR_COMPONENTS
   
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
GRANT EXECUTE ON [WM].[lsp_Kit_Calc_Consumption_BOM] TO nSQL 
GO


