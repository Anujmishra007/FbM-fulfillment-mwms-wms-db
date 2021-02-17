IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[API].[isp_Get_SKU_Image_UR]') and objectproperty(id, N'IsProcedure') = 1)
   DROP PROC [API].[isp_Get_SKU_Image_UR]
GO
/****** Object:  StoredProcedure [API].[isp_Get_SKU_Image_UR]    Script Date: 7/7/2020 12:45:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/************************************************************************/  
/* Stored Proc: lsp_WM_Get_SKU_Image_URL                                */  
/* Creation Date: 11-Sep-2019                                           */  
/* Copyright: LF Logistics                                              */  
/* Written by: Shong                                                    */  
/*                                                                      */  
/* Purpose: Return Multiple URL Link for SKU Image                      */  
/*                                                                      */  
/*        :                                                             */  
/* Called By:                                                           */  
/*          :                                                           */  
/* PVCS Version: 1.0                                                    */  
/*                                                                      */  
/* Version: 8.0                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date        Author   Ver   Purposes                                  */  
/************************************************************************/  
CREATE PROC [API].[isp_Get_SKU_Image_UR]  
     @c_Storerkey          NVARCHAR(15)  
   , @c_SKU                NVARCHAR(20)  
   , @c_UserName           NVARCHAR(128) =''     
   , @b_Success            INT = 1           OUTPUT    
   , @n_err                INT = 0           OUTPUT                                                                                                               
   , @c_ErrMsg             NVARCHAR(255)= '' OUTPUT                   
AS  
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_NULLS OFF  
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   DECLARE @n_StartTCnt       INT  
         , @n_Continue        INT  
         , @c_SQL             NVARCHAR(2000)  
         , @c_SQL_Parm        NVARCHAR(2000)   
  
   DECLARE @c_NSQLDescrip     NVARCHAR(215),   
           @c_SKUImageURL     NVARCHAR(1000),   
           @c_CustStoredProc  NVARCHAR(100) = ''  
  
   --SET @n_StartTCnt = @@TRANCOUNT  
   --SET @n_Continue = 1  
   --SET @n_err      = 0  
   --SET @c_errmsg   = ''  
  
   --SET @n_Err = 0   
   --EXEC [WM].[lsp_SetUser] @c_UserName = @c_UserName, @n_Err = @n_Err OUTPUT, @c_ErrMsg = @c_ErrMsg OUTPUT  
     
   --IF @n_Err <> 0   
   --BEGIN  
   --   GOTO EXIT_SP  
   --END  
  
   --SELECT @c_CustStoredProc = ISNULL(SValue,'')  
   --FROM StorerConfig (NOLOCK)  
   --WHERE ConfigKey='GetSKUURL'  
   --AND SValue > ''  
   --AND OPTION5 IS NOT NULL  
     
   --IF NOT EXISTS ( SELECT 1   
   --                FROM dbo.sysobjects WHERE  id = OBJECT_ID(@c_CustStoredProc)   
   --                AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 )  
   --BEGIN  
   -- GOTO URL_STANDARD  
   --END   
      
   --SET @c_SQL = N'EXEC ' +  @c_CustStoredProc  +   
   --      '   @c_Storerkey = @c_Storerkey' +   
   --      ' , @c_SKU = @c_SKU ' +   
   --      ' , @c_UserName = @c_UserName' +   
   --      ' , @b_Success = @b_Success OUTPUT ' +     
   --      ' , @n_err = @n_Err OUTPUT ' +    
   --      ' , @c_ErrMsg = @c_ErrMsg OUTPUT '  
            
   --SET @c_SQL_Parm =   
   --      N'  @c_Storerkey NVARCHAR(15) ' +   
   --      N', @c_SKU NVARCHAR(20) ' +   
   --      N', @c_UserName NVARCHAR(128) ' +     
   --      N', @b_Success INT OUTPUT ' +   
   --      N', @n_err INT OUTPUT ' +   
   --      N', @c_ErrMsg NVARCHAR(255) OUTPUT '     
      
   --EXEC sp_ExecuteSQL @c_SQL, @c_SQL_Parm, @c_Storerkey, @c_SKU, @c_UserName, @b_Success OUTPUT, @n_err OUTPUT, @c_ErrMsg OUTPUT  
     
   --GOTO EXIT_SP  
  
   ---  URL_STANDARD ---  
   URL_STANDARD:     
   SET @c_SKUImageURL = ''  
   SET @c_NSQLDescrip = ''  
   SELECT @c_NSQLDescrip = NSQLDescrip  
   FROM NSQLCONFIG (NOLOCK)  
   WHERE ConfigKey='SkuImageServer'  
   AND NSQLValue='1'  
     
   IF @c_NSQLDescrip > ''  
   BEGIN  
    SET @c_SKUImageURL = ''  
      
      SELECT @c_SKUImageURL = s.BUSR4  
      FROM SKU AS s WITH(NOLOCK)  
      WHERE s.StorerKey = @c_Storerkey  
      AND s.Sku = @c_SKU  
              
      IF @c_SKUImageURL <> ''  
      BEGIN  
       IF CHARINDEX(@c_NSQLDescrip, @c_SKUImageURL) = 0   
       BEGIN  
        SET @c_SKUImageURL = ''  
       END  
       ELSE   
       BEGIN  
            SELECT @c_Storerkey  AS [StorerKey],   
                   @c_SKU        AS [SKU],  
                   @c_SKUImageURL AS [ImageURL]            
       END  
      END   
   END  
     
   IF @c_SKUImageURL = ''   
   BEGIN  
      SELECT @c_Storerkey AS [StorerKey],   
               @c_SKU       AS [SKU],  
               'https://intranetapi.lfuat.net/GenericAPI/GetFile?src=IcOC6d%2BAoBNa16e0gLVR7PS6th0bgaLCsPIZ9M4UmX2CNC%2Fz69UrlCEmIguGHETX%2Bo1U7b8omrkl%2Bw9qT75BasN0VsuVylaxFaAgqXjo%2FlpuCd15Vao%2B6xpSHzVX1LVQzEk2HRWABiY%3D'                 
   END     
        
   EXIT_SP:  
END -- procedure  

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.isp_Get_SKU_Image_UR TO NSQL
GO

