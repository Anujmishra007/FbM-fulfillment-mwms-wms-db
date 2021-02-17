IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[isp_WebAPI_LCHART_GetConf]') 
AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[isp_WebAPI_LCHART_GetConf]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO  
/************************************************************************/                
/* Store procedure: isp_WebAPI_LCHART_GetConf                           */                
/* Creation Date: 27-OCT-2017                                           */  
/* Copyright: IDS                                                       */  
/* Written by: AlexKeoh                                                 */  
/*                                                                      */  
/* Purpose: Pass Incoming Request String For Interface                  */  
/*                                                                      */  
/* Input Parameters:  @b_Debug            - 0                           */  
/*                    @c_Format           - 'XML/JSON'                  */  
/*                    @c_UserID           - 'UserName'                  */  
/*                    @c_OperationType    - 'Operation'                 */  
/*                    @c_RequestString    - ''                          */  
/*                    @b_Debug            - 0                           */  
/*                                                                      */  
/* Output Parameters: @b_Success          - Success Flag    = 0         */  
/*                    @c_ErrNo            - Error No        = 0         */  
/*                    @c_ErrMsg           - Error Message   = ''        */  
/*                    @c_ResponseString   - ResponseString  = ''        */  
/*                                                                      */  
/* Called By: LeafAPIServer - isp_Generic_WebAPI_Request                */  
/*                                                                      */  
/* PVCS Version: 1.0                                                    */  
/*                                                                      */  
/* Version: 1.0                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date        Author   Purposes              */  
/************************************************************************/      
CREATE PROC [dbo].[isp_WebAPI_LCHART_GetConf](  
     @b_Debug           INT            = 0  
   , @c_Format          VARCHAR(10)    = ''  
   , @c_UserID          NVARCHAR(256)  = ''  
   , @c_OperationType   NVARCHAR(60)   = ''  
   , @c_RequestString   NVARCHAR(MAX)  = ''  
   , @b_Success         INT            = 0   OUTPUT  
   , @n_ErrNo           INT            = 0   OUTPUT  
   , @c_ErrMsg          NVARCHAR(250)  = ''  OUTPUT  
   , @c_ResponseString  NVARCHAR(MAX)  = ''  OUTPUT  
)  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_DEFAULTS OFF   
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
     
   DECLARE @n_Continue                    INT  
         , @n_StartCnt                    INT  
         , @c_ExecStatements              NVARCHAR(MAX)  
         , @c_ExecArguments               NVARCHAR(2000)  
         , @x_xml                         XML  
         , @n_doc                         INT  
         , @c_XMLRequestString            NVARCHAR(MAX)  
  
         , @c_Request_XMLNodes            NVARCHAR(60)  
           
         , @c_HostKey                     NVARCHAR(40)  
         , @c_Action                      NVARCHAR(20)  
         , @c_ListNameGTPStorer           NVARCHAR(15)  
  
   SET @n_Continue                        = 1  
   SET @n_StartCnt                        = @@TRANCOUNT  
   SET @b_Success                         = 0  
   SET @n_ErrNo                           = 0  
   SET @c_ErrMsg                          = ''  
   SET @c_ResponseString                  = ''   
   SET @c_XMLRequestString                = ''  
     
   SET @c_HostKey                         = ''  
   SET @c_Action                 = ''  
   SET @c_ListNameGTPStorer               = 'GTPStorer'  
  
   IF @c_Format = 'json'  
   BEGIN  
      SET @c_XMLRequestString = MASTER.dbo.fnc_JSON2XML(@c_RequestString, '')  
        
      -- Convert special HTML character to normal character   
      IF CHARINDEX(N'&#', @c_XMLRequestString, 1) > 0   
      BEGIN  
         SELECT @c_XMLRequestString = CAST(@c_XMLRequestString as XML).value('text()[1]','nvarchar(max)')            
      END  
  
      SET @x_xml = CONVERT(XML, @c_XMLRequestString)  
  
      IF @b_Debug = 1  
      BEGIN  
         PRINT '>>>>>>>>>> JSONCONVERTTOXML' + CHAR(13) + @c_XMLRequestString  
      END  
   END  
   ELSE  
   BEGIN  
      SET @x_xml = CONVERT(XML, @c_RequestString)  
   END  
  
   IF @n_Continue = 1  
   BEGIN  
      EXEC sp_xml_preparedocument @n_doc OUTPUT, @x_xml  
        
      --Read data from XML  
      SELECT @c_Action        = ISNULL(RTRIM([Action]), '')  
      FROM OPENXML (@n_doc, 'Request', 1)  
      WITH (  
         [Action]          NVARCHAR(15)         'Action'  
      )  
        
      EXEC sp_xml_removedocument @n_doc  
  
      IF @c_Action = ''  
      BEGIN  
         SET @n_Continue = 3  
         SET @n_ErrNo = 50400  
         SET @c_ErrMsg = 'Invalid Action. '  
         GOTO QUIT  
      END  
  
      IF @c_Action = 'GetStorerList'  
      BEGIN  
         SET @c_ExecStatements = CASE WHEN @c_Format = 'json'   
                                  THEN ';WITH XMLNAMESPACES (''http://james.newtonking.com/projects/json'' as json) ' END  
                               + ' SELECT @c_ResponseString = ISNULL(RTRIM(CONVERT(NVARCHAR(MAX),( '  
                               + ' SELECT '  
                               + CASE WHEN @c_Format = 'json'   
                                  THEN ' ''true'' AS [@json:Array], ' ELSE '' END  
                               + ' cdlkup.Code, '  
                               + ' ( '  
                               + '   SELECT '  
                               + CASE WHEN @c_Format = 'json'  THEN ' ''true'' AS [@json:Array], ' END   
                               + '   cdlkup2.StorerKey, cdlkup2.UDF01 '  
                               + '   FROM dbo.Codelkup cdlkup2 WITH (NOLOCK)  '  
                               + '   WHERE cdlkup2.Listname = @c_ListNameGTPStorer '  
                               + '   AND cdlkup2.Code = cdlkup.Code '  
                               + '   FOR XML PATH(''Storer''), TYPE '  
                               + ' ) '  
                               + ' FROM dbo.Codelkup cdlkup WITH (NOLOCK) '  
                               + ' WHERE cdlkup.Listname = @c_ListNameGTPStorer '  
                               + ' GROUP BY cdlkup.Code '   
                               + ' FOR XML PATH (''StorerGroup''), type'  
                               + CASE WHEN @c_Format = 'json'  
                                  THEN ', ROOT(''Root'') ' END  
                               + ' ))), '''')'  
  
         SET @c_ExecArguments = ' @c_ListNameGTPStorer NVARCHAR(15), @c_ResponseString NVARCHAR(MAX) OUTPUT'  
  
         EXEC sp_ExecuteSql @c_ExecStatements  
                          , @c_ExecArguments  
                          , @c_ListNameGTPStorer  
                          , @c_ResponseString OUTPUT  
  
         SET @c_ResponseString = IIF(@c_Format = 'json', master.dbo.fnc_XML2JSON(@c_ResponseString, 1), @c_ResponseString)  
      END  
  
      IF @b_Debug = 1  
      BEGIN  
         PRINT '>>>>>>>>>> ResponseString' + CHAR(13) + @c_ResponseString  
      END  
   END  
   ELSE  
   BEGIN  
      SET @n_Continue = 3  
      SET @n_ErrNo = 50401  
      SET @c_ErrMsg = 'Action [' + @c_Action + '] is not available.'  
      GOTO QUIT  
   END  
  
   QUIT:  
   IF @n_Continue= 3  -- Error Occured - Process And Return        
   BEGIN        
      SET @b_Success = 0        
      IF @@TRANCOUNT > @n_StartCnt AND @@TRANCOUNT = 1   
      BEGIN                 
         ROLLBACK TRAN        
      END        
      ELSE        
      BEGIN        
         WHILE @@TRANCOUNT > @n_StartCnt        
         BEGIN        
            COMMIT TRAN        
         END        
      END     
      RETURN        
   END        
   ELSE        
   BEGIN        
      SELECT @b_Success = 1        
      WHILE @@TRANCOUNT > @n_StartCnt        
      BEGIN        
         COMMIT TRAN        
      END        
      RETURN        
   END  
END -- Procedure    