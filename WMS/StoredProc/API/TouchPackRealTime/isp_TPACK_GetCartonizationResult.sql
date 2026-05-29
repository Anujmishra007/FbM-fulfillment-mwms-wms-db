SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/***************************************************************************************/
/* Stored Proc: isp_TPACK_GetCartonizationResult                                       */
/* Copyright      : Maersk                                                             */
/*                                                                                     */
/* Purpose        : Retrieve cartonization results for a given carton group and type   */
/*                                                                                     */
/* Date         Rev  Author     Purposes                                               */
/* 2026-05-20   1.0  GCH225     UWP-54223: Created                                     */
/***************************************************************************************/
CREATE OR ALTER PROC [API].[isp_TPACK_GetCartonizationResult]
     @c_CartonGroup  NVARCHAR(10) 
   , @c_CartonType   NVARCHAR(10) 
   , @c_Algorithm    NVARCHAR(30)   = ''
   , @cLangCode      NVARCHAR(10)   = ''
   , @b_Success      INT            = 0  OUTPUT
   , @n_ErrNo        INT            = 0  OUTPUT
   , @c_ErrMsg       NVARCHAR(250)  = '' OUTPUT         
   , @b_Debug        INT            = 0
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
     , @c_Sku                 NVARCHAR(20)  = ''      
     , @n_Length              DECIMAL(10,6) = 0.000000
     , @n_Width               DECIMAL(10,6) = 0.000000
     , @n_Height              DECIMAL(10,6) = 0.000000
         
   SELECT @n_Length = CONVERT(DECIMAL(10,6), CartonLength)    
         ,@n_Width  = CONVERT(DECIMAL(10,6), CartonWidth )    
         ,@n_Height = CONVERT(DECIMAL(10,6), CartonHeight)    
   FROM CARTONIZATION (NOLOCK)      
   WHERE CartonizationGroup = @c_CartonGroup      
   AND CartonType =  @c_CartonType    
       
   IF @n_Length = 0.000000 
   OR @n_Width = 0.000000 
   OR @n_Height = 0.000000    
   BEGIN    
      SET @n_Continue = 3    
      SET @n_ErrNo = 16051
      SET @c_ErrMsg = '(' + @c_CartonType + ') ' + API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') -- 'Zero Length/width/height found for Carton Type.'
      GOTO EXIT_SP      
   END 
   
   SET @c_ContainerString = (
   SELECT 0 AS ID
        , CONVERT(DECIMAL(10,6), ctn.CartonLength) AS [Length] 
        , CONVERT(DECIMAL(10,6), ctn.CartonWidth ) AS [Width]
        , CONVERT(DECIMAL(10,6), ctn.CartonHeight) AS [Height]
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
      SET @n_ErrNo = 16052
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') -- Cartonization Info not found.
      GOTO EXIT_SP  
   END
  
   IF OBJECT_ID('tempdb..#OptimizeItemToPack','U') IS NOT NULL
   BEGIN
      SELECT TOP 1 @c_Sku = SKU     
      FROM #OptimizeItemToPack (NOLOCK)     
      WHERE Dim1 = 0.000000 
      OR Dim2 = 0.000000 
      OR Dim3 = 0.000000 
      
      SET @c_PackItemString = ( 
         SELECT  oitp.ID
               , oitp.SKU  AS [Name]
               , oitp.Dim1
               , oitp.Dim2
               , oitp.Dim3
               , oitp.Quantity
         FROM #OptimizeItemToPack AS oitp WITH(NOLOCK)    
         FOR JSON PATH, ROOT('ItemsToPack') 
         )
   END
   
   IF @c_Sku <> ''    
   BEGIN    
      SET @n_Continue = 3     
      SET @n_ErrNo = 16053
      SET @c_ErrMsg = '(' + @c_Sku + ') ' + API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') --Zero Length/width/height found for Sku
      GOTO EXIT_SP        
   END    
   
   IF @b_Debug = 1
      PRINT '@c_PackItemString >> ' + @c_PackItemString

   IF '{' + @c_PackItemString + '}' = '{}'
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = 16054
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') -- Pack Item info not found.
      GOTO EXIT_SP  
   END

   SET @c_RequestString = '{' + 
      CASE WHEN ISNULL(@c_Algorithm,'') <> '' 
            THEN '"Algorithm":"' + RTRIM(@c_Algorithm) + '",' 
            ELSE '' END +
      SUBSTRING(@c_ContainerString, 2, LEN(@c_ContainerString) - 2) + 
      ',' +
      SUBSTRING(@c_PackItemString, 2, LEN(@c_PackItemString) - 2) +
      '}'   	  
 
   IF @b_Debug = 1
      PRINT '@c_RequestString >>' + @c_RequestString 

   SET @n_Exists              = 0
   SET @c_WebRequestMethod    = 'POST'  
   SET @c_ContentType         = 'application/json'  
   SET @c_WebRequestEncoding  = 'UTF-8'  
   SET @c_WS_url              = ''
        
   SELECT @c_WS_url = ISNULL(RTRIM(Long), '')   
      , @c_IniFilePath = ISNULL(RTRIM(Notes), '')   
   FROM dbo.Codelkup WITH (NOLOCK)   
   WHERE Listname = 'TPS-WebSvc'  
   AND Code = 'CartonizationAPI'
      
   IF @c_WS_url = '' OR @c_IniFilePath = ''  
   BEGIN  
      SET @n_Continue = 3
      SET @n_ErrNo = 16055
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') -- Web Service URL or Ini File Path not configured for Cartonization API.
      GOTO EXIT_SP 
   END
    
   BEGIN TRY
      SET @c_vbErrMsg = '' 
      EXEC MASTER.dbo.isp_GenericWebServiceClientV5 
            @c_IniFilePath                = @c_IniFilePath
            ,@c_WebRequestURL             = @c_WS_url
            ,@c_WebRequestMethod          = @c_WebRequestMethod      
            ,@c_ContentType               = @c_ContentType
            ,@c_WebRequestEncoding        = @c_WebRequestEncoding
            ,@c_RequestString             = @c_RequestString
            ,@c_ResponseString            = @c_ResponseString     OUTPUT
            ,@c_vbErrMsg                  = @c_vbErrMsg           OUTPUT 
            ,@n_WebRequestTimeout         = 120000    --@n_WebRequestTimeout -- Miliseconds  
            ,@c_NetworkCredentialUserName =''         --@c_NetworkCredentialUserName -- leave blank if no network credential  
            ,@c_NetworkCredentialPassword =''         --@c_NetworkCredentialPassword -- leave blank if no network credential  
            ,@b_IsSoapRequest             = 0         --@b_IsSoapRequest  -- 1 = Add SoapAction in HTTPRequestHeader  
            ,@c_RequestHeaderSoapAction   = ''        --@c_RequestHeaderSoapAction -- HTTPRequestHeader SoapAction value  
            ,@c_HeaderAuthorization       = ''        --@c_HeaderAuthorization  
            ,@c_ProxyByPass               = '1'       --@c_ProxyByPass, 1 >> Set Ip & Port, 0 >> Set Nothing, '' >> Skip Setup   
            ,@c_WebRequestHeaders         = ''
            ,@c_vbHttpStatusCode          = '' 
            ,@c_vbHttpStatusDesc          = '' 

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
      SET @n_ErrNo = 16056
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') + ' ' + @c_vbErrMsg -- Error occurred while calling Cartonization API.
      GOTO EXIT_SP
   END

   SELECT ContainerID, AlgorithmID, IsCompletePack, ID, SKU, Qty
   FROM OPENJSON(@c_ResponseString)
   WITH (
         ContainerID             VARCHAR(10)    'strict $.ContainerID'
       , AlgorithmPackingResults NVARCHAR(MAX)  '$.AlgorithmPackingResults' AS JSON 
   ) AS Container
   CROSS APPLY OPENJSON(AlgorithmPackingResults,'$')
      WITH (
            AlgorithmID       VARCHAR(10)    '$.AlgorithmID'
          , IsCompletePack    VARCHAR(10)    '$.IsCompletePack'
          , PackedItemsGroup  NVARCHAR(MAX)  '$.PackedItemsGroup' AS JSON
      ) AS Algorithm
      CROSS APPLY OPENJSON(PackedItemsGroup,'$')
      WITH (
           ID  VARCHAR(10) '$.ID'
         , SKU VARCHAR(20) '$.Name'
         , Qty INT         '$.Quantity'
      )
   ;
   
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

      EXECUTE nsp_logerror @n_ErrNo, @c_ErrMsg, 'isp_TPACK_GetCartonizationResult'
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
