IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[WM].[lsp_SOCombineORD_Wrapper]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [WM].[lsp_SOCombineORD_Wrapper] 
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO   
/************************************************************************/                                                                                  
/* Store Procedure: WM.lsp_SOCombineORD_Wrapper                         */                                                                                  
/* Creation Date: 2020-07-14                                            */                                                                                  
/* Copyright: LFL                                                       */                                                                                  
/* Written by: Wan                                                      */                                                                                  
/*                                                                      */                                                                                  
/* Purpose: LFWM-2193 -Ship Reference Unit  Stored ProceduresSQL queries*/
/*                                                                      */                                                                                  
/* Called By: SCE                                                       */                                                                                  
/*          :                                                           */                                                                                  
/* PVCS Version: 1.0                                                    */                                                                                  
/*                                                                      */                                                                                  
/* Version: 8.0                                                         */                                                                                  
/*                                                                      */                                                                                  
/* Data Modifications:                                                  */                                                                                  
/*                                                                      */                                                                                  
/* Updates:                                                             */                                                                                  
/* Date        Author   Ver.  Purposes                                  */  
/************************************************************************/                                                                                  
CREATE PROC [WM].[lsp_SOCombineORD_Wrapper] 
      @c_ToOrderKey           NVARCHAR(10)
   ,  @c_OrderKeys            NVARCHAR(4000)             --List of OrderKeys, seperated by '|'
   ,  @b_Success              INT = 1           OUTPUT  
   ,  @n_err                  INT = 0           OUTPUT                                                                                                             
   ,  @c_ErrMsg               NVARCHAR(255)     OUTPUT 
   ,  @n_WarningNo            INT          = 0  OUTPUT   --Initial to Pass in '1', Pass In the value return By SP except RE-Finalize. RE-Finalize get logwarningno to pass in
   ,  @c_ProceedWithWarning   CHAR(1)      = 'N'                     
   ,  @c_UserName             NVARCHAR(128)= ''                                                                                                                         
   ,  @n_ErrGroupKey          INT          = 0  OUTPUT   --Capture Warnings/Questions/Errors/Meassage into WMS_ERROR_LIST Table
AS  
BEGIN                                                                                                                                                        
   SET NOCOUNT ON                                                                                                                                           
   SET ANSI_NULLS OFF                                                                                                                                       
   SET QUOTED_IDENTIFIER OFF                                                                                                                                
   SET CONCAT_NULL_YIELDS_NULL OFF       

   DECLARE  @n_StartTCnt                  INT            = @@TRANCOUNT  
         ,  @n_Continue                   INT            = 1

         ,  @c_TableName                  NVARCHAR(50)   = 'ORDERS'
         ,  @c_SourceType                 NVARCHAR(50)   = 'lsp_SOCombineORD_Wrapper'

         ,  @n_RowID                      INT            = 0

         ,  @c_BuyerPO                    NVARCHAR(20)   = ''
         ,  @c_ToOrderKey_New             NVARCHAR(10)   = ''

         ,  @c_PreOrderKeys               NVARCHAR(4000) = ''
         ,  @c_ToFacility                 NVARCHAR(5)    = ''
         ,  @c_ToStorerkey                NVARCHAR(15)   = ''
         ,  @c_ToShipTo                   NVARCHAR(15)   = ''
         ,  @c_ToOrderStatus              NVARCHAR(10)   = ''

         ,  @c_FromOrderkey               NVARCHAR(10)   = ''

         ,  @c_CombineOrd_SP              NVARCHAR(30)   = ''
         ,  @CUR_CBMORD                   CURSOR
  
  

   SET @b_Success = 1
   SET @n_Err     = 0
               
   SET @n_Err = 0 
   EXEC [WM].[lsp_SetUser] 
         @c_UserName = @c_UserName  OUTPUT
      ,  @n_Err      = @n_Err       OUTPUT
      ,  @c_ErrMsg   = @c_ErrMsg    OUTPUT
                
   EXECUTE AS LOGIN = @c_UserName
   
   IF OBJECT_ID('tempdb..#FROMORD','U') IS NOT NULL
   BEGIN
      DROP TABLE #FROMORD
   END

   CREATE TABLE #FROMORD
      (  RowID    INT            NOT NULL IDENTITY(1,1)  PRIMARY KEY
      ,  Orderkey NVARCHAR(10)   NOT NULL DEFAULT('')
      ) 

   IF @n_Err <> 0 
   BEGIN
      GOTO EXIT_SP
   END

   IF @n_ErrGroupKey IS NULL
   BEGIN
      SET @n_ErrGroupKey = 0
   END

   INSERT INTO #FROMORD (  OrderKey )
   SELECT DISTINCT Orderkey = VALUE FROM string_split (@c_OrderKeys,'|')
   ORDER BY Orderkey

   SET @c_PreOrderKeys = @c_OrderKeys

   SELECT @c_BuyerPO = ISNULL(RTRIM(OH.BuyerPO),'')
   FROM ORDERS OH WITH (NOLOCK)
   WHERE OH.Orderkey = @c_ToOrderkey

   
   select @c_ToOrderKey '@c_ToOrderKey 1'
   IF @c_BuyerPO <> '' -- Get the TO Orderkey if buyerpo not the min value
   BEGIN
      SET @c_ToOrderKey_New = ''
      SELECT TOP 1 @c_ToOrderKey_New = OH.Orderkey
                  ,@n_RowId = TORD.RowID
      FROM #FROMORD TORD
      JOIN ORDERS OH WITH (NOLOCK) ON TORD.Orderkey = OH.OrderKey
      ORDER BY ISNULL(OH.BuyerPO,'') 


      IF @c_ToOrderKey_New < @c_ToOrderKey
      BEGIN
         DELETE #FROMORD WHERE RowID = @n_RowId
 
         INSERT INTO #FROMORD (Orderkey) VALUES (@c_ToOrderKey)
 
         SET @c_PreOrderKeys = REPLACE(@c_PreOrderKeys, @c_ToOrderKey_New, @c_ToOrderKey)

         SET @c_ToOrderKey = @c_ToOrderKey_New
      END
   END -- END

   select @c_ToOrderKey '@c_ToOrderKey 2'
   SELECT @c_ToFacility    = OH.Facility
      ,   @c_ToStorerkey   = OH.Storerkey
      ,   @c_ToShipTo      = OH.ConsigneeKey
      ,   @c_ToOrderStatus = OH.[Status]
   FROM ORDERS OH WITH (NOLOCK)
   WHERE OH.Orderkey = @c_ToOrderKey
   
   SELECT @c_CombineOrd_SP = Authority FROM dbo.fnc_SelectGetRight(@c_ToFacility, @c_ToStorerkey, '', 'CombineOrderSP')

   IF @c_CombineOrd_SP IN ( '0','1','' )
   BEGIN
      SET @n_Continue = 3
      SET @n_err = 558451
      SET @c_errmsg = 'NSQL'+ CONVERT(Char(6),@n_err) + ': Custom CombineOrderSP Not setup'  
                  + '. (lsp_SOCombineORD_Wrapper)'

      EXEC [WM].[lsp_WriteError_List] 
            @i_iErrGroupKey= @n_ErrGroupKey OUTPUT 
         ,  @c_TableName   = @c_TableName
         ,  @c_SourceType  = @c_SourceType
         ,  @c_Refkey1     = @c_ToOrderKey
         ,  @c_Refkey2     = ''
         ,  @c_Refkey3     = '' 
         ,  @c_WriteType   = 'ERROR' 
         ,  @n_err2        = @n_err 
         ,  @c_errmsg2     = @c_errmsg 
         ,  @b_Success     = @b_Success    
         ,  @n_err         = @n_err        
         ,  @c_errmsg      = @c_errmsg    
   END
   ELSE IF NOT EXISTS (SELECT 1 FROM SYS.OBJECTS WITH (NOLOCK) WHERE [Name] = @c_CombineOrd_SP AND [Type] = 'P' )
   BEGIN 
      SET @n_Continue = 3
      SET @n_err = 558452
      SET @c_errmsg = 'NSQL'+ CONVERT(Char(6),@n_err) + ': Custom SP: ' + @c_CombineOrd_SP + ' not found'  
                  + '. (lsp_SOCombineORD_Wrapper) |' + @c_CombineOrd_SP

      EXEC [WM].[lsp_WriteError_List] 
            @i_iErrGroupKey= @n_ErrGroupKey OUTPUT 
         ,  @c_TableName   = @c_TableName
         ,  @c_SourceType  = @c_SourceType
         ,  @c_Refkey1     = @c_ToOrderKey
         ,  @c_Refkey2     = ''
         ,  @c_Refkey3     = '' 
         ,  @c_WriteType   = 'ERROR' 
         ,  @n_err2        = @n_err 
         ,  @c_errmsg2     = @c_errmsg 
         ,  @b_Success     = @b_Success    
         ,  @n_err         = @n_err        
         ,  @c_errmsg      = @c_errmsg  
   END
        
   BEGIN TRY
      SET @b_Success = 1
      SET @n_err = 0
      EXEC isp_PreCombineOrder_Wrapper
            @c_ToOrderkey  = @c_ToOrderKey
         ,  @c_OrderList   = @c_PreOrderKeys
         ,  @b_Success     = @b_Success   OUTPUT
         ,  @n_Err         = @n_Err       OUTPUT
         ,  @c_ErrMsg      = @c_ErrMsg    OUTPUT
   END TRY

   BEGIN CATCH
      SET @n_err = 558453
      SET @c_ErrMsg = ERROR_MESSAGE()
   END CATCH

   IF @b_Success = 0
   BEGIN
      SET @n_err = 558453
   END

   IF @n_err <> 0
   BEGIN
      SET @n_continue = 3
      SET @c_errmsg = 'NSQL'+ CONVERT(Char(6),@n_err) + ': Error Executing isp_PreCombineOrder_Wrapper. (lsp_SOCombineORD_Wrapper)'
                  + ' ( ' + @c_ErrMsg + ' )'

      EXEC [WM].[lsp_WriteError_List] 
            @i_iErrGroupKey= @n_ErrGroupKey OUTPUT 
         ,  @c_TableName   = @c_TableName
         ,  @c_SourceType  = @c_SourceType
         ,  @c_Refkey1     = @c_ToOrderKey
         ,  @c_Refkey2     = ''
         ,  @c_Refkey3     = '' 
         ,  @c_WriteType   = 'ERROR' 
         ,  @n_err2        = @n_err 
         ,  @c_errmsg2     = @c_errmsg 
         ,  @b_Success     = @b_Success    
         ,  @n_err         = @n_err        
         ,  @c_errmsg      = @c_errmsg    
   END

   --- Check ToShip, Storerkey, ORder Status
  
   SET @c_FromOrderkey = ''
   SELECT TOP 1 @c_FromOrderkey = OH.Orderkey
   FROM #FROMORD TORD
   JOIN ORDERS OH WITH (NOLOCK) ON TORD.Orderkey = OH.OrderKey
   WHERE OH.Storerkey <> @c_ToStorerkey

   IF @c_FromOrderkey <> ''
   BEGIN
      SET @n_Continue = 3
      SET @n_err = 558454
      SET @c_errmsg = 'NSQL'+ CONVERT(Char(6),@n_err) + ': Invalid selected Order: ' + @c_FromOrderkey 
                  + '. Cannot combine different Storer. (lsp_SOCombineORD_Wrapper)'

      EXEC [WM].[lsp_WriteError_List] 
            @i_iErrGroupKey= @n_ErrGroupKey OUTPUT 
         ,  @c_TableName   = @c_TableName
         ,  @c_SourceType  = @c_SourceType
         ,  @c_Refkey1     = @c_ToOrderKey
         ,  @c_Refkey2     = ''
         ,  @c_Refkey3     = '' 
         ,  @c_WriteType   = 'ERROR' 
         ,  @n_err2        = @n_err 
         ,  @c_errmsg2     = @c_errmsg 
         ,  @b_Success     = @b_Success    
         ,  @n_err         = @n_err        
         ,  @c_errmsg      = @c_errmsg    
   END

   SET @c_FromOrderkey = ''
   SELECT TOP 1 @c_FromOrderkey = OH.Orderkey
   FROM #FROMORD TORD
   JOIN ORDERS OH WITH (NOLOCK) ON TORD.Orderkey = OH.OrderKey
   WHERE OH.ConsigneeKey <> @c_ToShipTo

   IF @c_FromOrderkey <> ''
   BEGIN
      SET @n_Continue = 3
      SET @n_err = 558455
      SET @c_errmsg = 'NSQL'+ CONVERT(Char(6),@n_err) + ': Invalid selected Order: ' + @c_FromOrderkey 
                  + '. Cannot combine different Consigneekey. (lsp_SOCombineORD_Wrapper)'

      EXEC [WM].[lsp_WriteError_List] 
            @i_iErrGroupKey= @n_ErrGroupKey OUTPUT 
         ,  @c_TableName   = @c_TableName
         ,  @c_SourceType  = @c_SourceType
         ,  @c_Refkey1     = @c_ToOrderKey
         ,  @c_Refkey2     = ''
         ,  @c_Refkey3     = '' 
         ,  @c_WriteType   = 'ERROR' 
         ,  @n_err2        = @n_err 
         ,  @c_errmsg2     = @c_errmsg 
         ,  @b_Success     = @b_Success    
         ,  @n_err         = @n_err        
         ,  @c_errmsg      = @c_errmsg    
   END

   SET @c_FromOrderkey = ''
   SELECT TOP 1 @c_FromOrderkey = OH.Orderkey
   FROM #FROMORD TORD
   JOIN ORDERS OH WITH (NOLOCK) ON TORD.Orderkey = OH.OrderKey
   WHERE OH.[Status] <> @c_ToOrderStatus

   IF @c_FromOrderkey <> ''
   BEGIN
      SET @n_Continue = 3
      SET @n_err = 558456
      SET @c_errmsg = 'NSQL'+ CONVERT(Char(6),@n_err) + ': Invalid selected Order: ' + @c_FromOrderkey 
                  + '. Cannot combine different Status. (lsp_SOCombineORD_Wrapper)'

      EXEC [WM].[lsp_WriteError_List] 
            @i_iErrGroupKey= @n_ErrGroupKey OUTPUT 
         ,  @c_TableName   = @c_TableName
         ,  @c_SourceType  = @c_SourceType
         ,  @c_Refkey1     = @c_ToOrderKey
         ,  @c_Refkey2     = ''
         ,  @c_Refkey3     = '' 
         ,  @c_WriteType   = 'ERROR' 
         ,  @n_err2        = @n_err 
         ,  @c_errmsg2     = @c_errmsg 
         ,  @b_Success     = @b_Success    
         ,  @n_err         = @n_err        
         ,  @c_errmsg      = @c_errmsg    
   END

   IF @n_Continue = 3
   BEGIN
      GOTO EXIT_SP
   END
      
   SET @CUR_CBMORD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT TORD.OrderKey
   FROM #FROMORD TORD
   WHERE TORD.OrderKey NOT IN ( @c_ToOrderKey )

   OPEN @CUR_CBMORD

   FETCH NEXT FROM @CUR_CBMORD INTO @c_FromOrderkey

   WHILE @@FETCH_STATUS <> -1
   BEGIN
      BEGIN TRY
         SET @b_Success = 1
         SET @n_Err = 0
         EXEC @c_CombineOrd_SP
            @c_FromOrderKey= @c_FromOrderKey
         ,  @c_ToOrderKey  = @c_ToOrderKey
         ,  @b_Success     = @b_Success   OUTPUT
         ,  @n_Err         = @n_Err       OUTPUT
         ,  @c_ErrMsg      = @c_ErrMsg    OUTPUT
      END TRY
         
      BEGIN CATCH
         SET @n_Err = 558457
         SET @c_ErrMsg = ERROR_MESSAGE()
      END CATCH

      IF @b_Success = 0
      BEGIN
         SET @n_Err = 558457
      END

      IF @n_Err <> 0
      BEGIN
         SET @n_Continue = 3
         SET @c_ErrMsg = 'NSQL'+ CONVERT(Char(6),@n_err) + ': Error Executing ' + @c_CombineOrd_SP
               + '. (lsp_SOCombineORD_Wrapper) ( ' + @c_ErrMsg + ' )'
         
         EXEC [WM].[lsp_WriteError_List] 
               @i_iErrGroupKey= @n_ErrGroupKey OUTPUT 
            ,  @c_TableName   = @c_TableName
            ,  @c_SourceType  = @c_SourceType
            ,  @c_Refkey1     = @c_ToOrderKey
            ,  @c_Refkey2     = @c_FromOrderKey
            ,  @c_Refkey3     = '' 
            ,  @c_WriteType   = 'ERROR' 
            ,  @n_err2        = @n_err 
            ,  @c_errmsg2     = @c_errmsg 
            ,  @b_Success     = @b_Success    
            ,  @n_err         = @n_err        
            ,  @c_errmsg      = @c_errmsg  

         GOTO EXIT_SP
      END

      FETCH NEXT FROM @CUR_CBMORD INTO @c_FromOrderkey
   END
   CLOSE @CUR_CBMORD
   DEALLOCATE @CUR_CBMORD

   IF @n_Continue = 1
   BEGIN
      SET @c_errmsg = 'Combine Order SuccessFully.'

      EXEC [WM].[lsp_WriteError_List] 
         @i_iErrGroupKey= @n_ErrGroupKey OUTPUT 
      ,  @c_TableName   = @c_TableName
      ,  @c_SourceType  = @c_SourceType
      ,  @c_Refkey1     = @c_ToOrderKey
      ,  @c_Refkey2     = ''
      ,  @c_Refkey3     = '' 
      ,  @c_WriteType   = 'MESSAGE' 
      ,  @n_err2        = @n_err 
      ,  @c_errmsg2     = @c_errmsg 
      ,  @b_Success     = @b_Success    
      ,  @n_err         = @n_err        
      ,  @c_errmsg      = @c_errmsg  
   END 
   
   EXIT_SP:

   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      SET @b_Success = 0
      IF  @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt
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
      SET @n_WarningNo = 0
      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'lsp_SOCombineORD_Wrapper'
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
      
   IF @@TRANCOUNT < @n_StartTCnt
   BEGIN
      BEGIN TRAN 
   END

   REVERT
END
GO
GRANT EXECUTE ON [WM].[lsp_SOCombineORD_Wrapper] TO nSQL 
GO  