IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_SubmitToCartonizeAPI]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_SubmitToCartonizeAPI]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Proc: isp_SubmitToCartonizeAPI                                */
/* Creation Date: 2020-09-04                                            */
/* Copyright: LF Logistics                                              */
/* Written by: Wan                                                      */
/*                                                                      */
/* Purpose:                                                             */
/*        :                                                             */
/* Called By:                                                           */
/*          :                                                           */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 09-OCT-2020 Wan      1.0   Created                                   */ 
/************************************************************************/
CREATE PROC isp_SubmitToCartonizeAPI
           @c_CartonGroup        NVARCHAR(10) 
         , @c_CartonType         NVARCHAR(10) 
         , @b_Success            INT            = 1 OUTPUT
         , @n_Err                INT            = 0 OUTPUT
         , @c_ErrMsg             NVARCHAR(255)  = ''OUTPUT
         , @b_Debug              INT            = 0
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

DECLARE
       @n_StartTCnt           INT = @@TRANCOUNT
     , @n_Continue            INT  = 1
     , @c_ContainerString     NVARCHAR(MAX) = '' 
     , @c_PackItemString      NVARCHAR(MAX) = ''
     , @c_RequestString       NVARCHAR(MAX) = ''
     , @c_ResponseString      NVARCHAR(MAX) = ''
     , @c_IniFilePath         VARCHAR(225)  = '' 
     , @c_WebRequestMethod    VARCHAR(10)   = ''
     , @c_ContentType         VARCHAR(100)  = ''
     , @c_WebRequestEncoding  VARCHAR(30)   = '' 
     , @c_WS_url              NVARCHAR(250) = '' 
     , @n_Exists              INT = 0
     , @c_vbErrMsg            NVARCHAR(MAX) = '' 
     , @c_vbHttpStatusCode    NVARCHAR(20)  = '' 
     , @c_vbHttpStatusDesc    NVARCHAR(1000)= '' 
         
   SET @c_ContainerString = (
   SELECT 0 AS ID,
          CONVERT(DECIMAL(10,6), ctn.CartonLength) AS [Length], 
          CONVERT(DECIMAL(10,6), ctn.CartonWidth ) AS [Width], 
          CONVERT(DECIMAL(10,6), ctn.CartonHeight) AS [Height]    --2020-10-21
   FROM CARTONIZATION AS ctn WITH(NOLOCK)
   WHERE ctn.CartonizationGroup= @c_CartonGroup
   AND ctn.CartonType =  @c_CartonType
   FOR JSON PATH, ROOT('Containers') 
   )
 
   IF @b_Debug = 1
   BEGIN
      PRINT '@c_ContainerString >>' + @c_ContainerString +'<<'
   END

   IF '{' + @c_ContainerString + '}' = '{}'
   BEGIN
      SET @n_Continue = 3
      SET @n_Err      = 89010
      SET @c_ErrMsg   = 'NSQL' + CONVERT(CHAR(5), @n_Err) + ':'
                      + 'Cartonization Info not found. (isp_SubmitToCartonizeAPI)'
      GOTO QUIT_SP  
   END
  
   --IF OBJECT_ID('tempdb..#t_ItemPack') IS NULL
   --BEGIN
   --   CREATE TABLE #t_ItemPack 
   --   (
   --      ID       INT         IDENTITY(0,1), 
   --      SKU      NVARCHAR(20)   ,
   --      Dim1     DECIMAL(10,6)  ,
   --      Dim2     DECIMAL(10,6)  ,
   --      Dim3     DECIMAL(10,6)  ,
   --      Quantity INT 
   --   )

   --   INSERT INTO #t_ItemPack (SKU, Dim1, Dim2, Dim3, Quantity)  
   --   SELECT p.Sku, 
   --   CONVERT(DECIMAL(10,6), (SKU.Length)), 
   --   CONVERT(DECIMAL(10,6), (SKU.Width)), 
   --   CONVERT(DECIMAL(10,6), (SKU.Height)),
   --   SUM(p.Qty) 
   --   FROM PICKDETAIL AS p WITH(NOLOCK) 
   --   JOIN SKU WITH (NOLOCK) ON SKU.StorerKey = p.Storerkey AND SKU.Sku = p.Sku 
   --   WHERE OrderKey = '0016847006' and p.sku in ('4252353', '4024221')
   --   GROUP BY p.Sku, SKU.Length, SKU.Width, SKU.Height
   --END
  
   SET @c_PackItemString = ( 
      SELECT 
      tip.ID, 
      tip.SKU  AS [Name], 
      tip.Dim1, 
      tip.Dim2, 
      tip.Dim3, 
      tip.Quantity
      FROM #t_ItemPack AS tip WITH(NOLOCK)    
      FOR JSON PATH, ROOT('ItemsToPack') 
      )
 
   IF @b_Debug = 1
      PRINT '@c_PackItemString >> ' + @c_PackItemString

   IF '{' + @c_PackItemString + '}' = '{}'
   BEGIN
      SET @n_Continue = 3
      SET @n_Err      = 89020
      SET @c_ErrMsg   = 'NSQL' + CONVERT(CHAR(5), @n_Err) + ':'
                      + 'Pack Item not found. (isp_SubmitToCartonizeAPI)'
      GOTO QUIT_SP  
   END

 
   SET @c_RequestString = '{' + 
      SUBSTRING(@c_ContainerString, 2, LEN(@c_ContainerString) - 2) + 
      ',' +
      SUBSTRING(@c_PackItemString, 2, LEN(@c_PackItemString) - 2) +
      '}'
 
   IF @b_Debug = 1
      PRINT '@c_RequestString >>' + @c_RequestString 

   SET @n_Exists = 0
   SET @c_WebRequestMethod                = 'POST'  
   SET @c_ContentType                     = 'application/json'  
   SET @c_WebRequestEncoding              = 'UTF-8'  
   SET @c_WS_url                          = ''
        
   SELECT   
        @n_Exists = (1)  
      , @c_WS_url = ISNULL(RTRIM(Long), '')   
      , @c_IniFilePath = ISNULL(RTRIM(Notes), '')   
   FROM dbo.Codelkup WITH (NOLOCK)   
   WHERE Listname = 'WebService'  
   AND Code = 'Cartonization'   
      
   IF @n_Exists = 0 OR @c_WS_url = '' OR @c_IniFilePath = ''  
   BEGIN  
      SET @n_Continue = 3
      SET @n_Err      = 89030
      SET @c_ErrMsg   = 'NSQL' + CONVERT(CHAR(5), @n_Err) + ':'
                      + 'Codelkup WebService setup not found or Reuired URL/ File Path not setup'
                      + '. (isp_SubmitToCartonizeAPI)'
      GOTO QUIT_SP  
   END
    
   BEGIN TRY
      SET @c_vbErrMsg = '' 
      EXEC MASTER.dbo.isp_GenericWebServiceClientV5 
            @c_IniFilePath = @c_IniFilePath
            ,@c_WebRequestURL = @c_WS_url
            ,@c_WebRequestMethod= @c_WebRequestMethod      
            ,@c_ContentType= @c_ContentType
            ,@c_WebRequestEncoding= @c_WebRequestEncoding
            ,@c_RequestString = @c_RequestString
            ,@c_ResponseString= @c_ResponseString         OUTPUT
            ,@c_vbErrMsg= @c_vbErrMsg                     OUTPUT 
            ,@n_WebRequestTimeout= 120000      --@n_WebRequestTimeout -- Miliseconds  
            ,@c_NetworkCredentialUserName=''   --@c_NetworkCredentialUserName -- leave blank if no network credential  
            ,@c_NetworkCredentialPassword=''   --@c_NetworkCredentialPassword -- leave blank if no network credential  
            ,@b_IsSoapRequest = 0              --@b_IsSoapRequest  -- 1 = Add SoapAction in HTTPRequestHeader  
            ,@c_RequestHeaderSoapAction = ''   --@c_RequestHeaderSoapAction -- HTTPRequestHeader SoapAction value  
            ,@c_HeaderAuthorization = ''       --@c_HeaderAuthorization  
            ,@c_ProxyByPass = '1'              --@c_ProxyByPass, 1 >> Set Ip & Port, 0 >> Set Nothing, '' >> Skip Setup   
            ,@c_WebRequestHeaders = ''
            ,@c_vbHttpStatusCode = '' 
            ,@c_vbHttpStatusDesc = '' 

      IF @b_Debug = 1 
      BEGIN
         PRINT @c_ResponseString
         PRINT '>>> @c_vbErrMsg - ' + @c_vbErrMsg
      END
                         
   END TRY  
   BEGIN CATCH  
      SET @c_vbErrMsg = CONVERT(NVARCHAR(5),ISNULL(ERROR_NUMBER() ,0)) + ' - ' + ERROR_MESSAGE()  
   
      IF @b_Debug = 1  
         PRINT '>>> WS CALL CATCH EXCEPTION - ' + @c_vbErrMsg  
   END CATCH  
   
   IF @c_vbErrMsg <> ''
   BEGIN
      SET @n_Continue = 3
      SET @n_Err      = 89010
      SET @c_ErrMsg   = 'NSQL' + CONVERT(CHAR(5), @n_Err) + ':'
                  + 'Error Executing isp_GenericWebServiceClientV5. (isp_SubmitToCartonizeAPI)'
                  + ' (' + @c_vbErrMsg + ')' 
      GOTO QUIT_SP
   END
   SELECT ContainerID, AlgorithmID, IsCompletePack, ID, SKU, Qty
   FROM OPENJSON(@c_ResponseString)
   WITH (
      ContainerID VARCHAR(10) 'strict $.ContainerID'
      , AlgorithmPackingResults NVARCHAR(MAX) '$.AlgorithmPackingResults' AS JSON 
   ) AS Container
   CROSS APPLY OPENJSON(AlgorithmPackingResults,'$')
      WITH (
         AlgorithmID VARCHAR(10) '$.AlgorithmID'
         ,IsCompletePack VARCHAR(10) '$.IsCompletePack'
         ,PackedItemsGroup nvarchar(MAX) '$.PackedItemsGroup' as JSON
      ) AS Algorithm
      CROSS APPLY OPENJSON(PackedItemsGroup,'$')
      WITH (
         ID VARCHAR(10) '$.ID'
         ,SKU VARCHAR(20) '$.Name'
         ,Qty INT '$.Quantity'
      )
   ;
   
   QUIT_SP:

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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'isp_SubmitToCartonizeAPI'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
END -- procedure
GO
GRANT EXECUTE ON [dbo].[isp_GetRDTPrintJob] TO nSQL 
GO