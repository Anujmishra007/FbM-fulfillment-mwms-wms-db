IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_CheckSupervisorRole]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
BEGIN 
   DROP PROCEDURE [dbo].[isp_CheckSupervisorRole]   
END
GO 

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/  
/* Stored Procedure: isp_CheckSupervisorRole                            */  
/* Creation Date: 15-Dec-2015                                           */  
/* Copyright: LF Logistics                                              */  
/* Written by:                                                          */  
/*                                                                      */  
/* Purpose: Check IDS_SUPERVISOR role                                   */  
/*        : SOS#357827                                                  */  
/* Called By: Pickdetail delete trigger                                 */  
/* PVCS Version: 1.0                                                    */  
/*                                                                      */  
/* Version: 7.0                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author    Ver Purposes                                  */  
/* 2017-Jan-19  CSCHONG   1.0 Revise the scripts using dynamic (CS01)   */  
/* 2020-Sept-22 kocy      1.1 Revise link server for CN use link_secure */
/*                             while other countries use link_local     */                          
/************************************************************************/  
CREATE PROCEDURE [dbo].[isp_CheckSupervisorRole]   
     @c_username    NVARCHAR(18)  
   , @c_Flag        NVARCHAR(10)  OUTPUT  
   , @b_Success     INT           OUTPUT    
   , @n_Err         INT           OUTPUT    
   , @c_ErrMsg      NVARCHAR(250) OUTPUT  
AS        
BEGIN   
    
  SET ANSI_NULLS ON  
  SET ANSI_WARNINGS ON  
  SET QUOTED_IDENTIFIER OFF  
    
    
  Declare @c_tsecurename     NVARCHAR(50)  
       ,  @c_SQL             NVARCHAR(MAX)    
       ,  @n_CNTRec          INT  
       ,  @c_ExecArguments   NVARCHAR(4000) 
       ,  @c_linksrvrname    NVARCHAR(50)
  
  SELECT @b_Success = 1, @n_Err = 0, @c_ErrMsg = '', @c_Flag = 'N',@c_tsecurename ='' --CS01 
  SELECT @c_linksrvrname = ''  --kocy
         
  SELECT @c_tsecurename = dbo.fnc_GetSecurityDBName()  

  SELECT @c_linksrvrname = CASE WHEN LEFT(RTRIM(DB_NAME()), 2 ) = 'CN' THEN 'link_secure' ELSE 'link_local' END  --kocy
    
     IF ISNULL(@c_username,'') = ''  
     SELECT @c_username = SUSER_SNAME()  
       
/*CS01 start*/      
/*  IF EXISTS (SELECT 1   
             FROM link_local.tsecure.dbo.pl_usr pl_usr (NOLOCK)   
             LEFT JOIN link_local.tsecure.dbo.pl_grp_usr pl_grp_usr (NOLOCK) ON pl_usr.usr_key = pl_grp_usr.usr_key  
             LEFT JOIN link_local.tsecure.dbo.pl_grp_role pl_grp_role (NOLOCK) ON pl_grp_usr.grp_key = pl_grp_role.grp_key AND pl_grp_role.app_key = 1  
             LEFT JOIN link_local.tsecure.dbo.pl_role pl_rolegrp (NOLOCK) ON pl_grp_role.role_key = pl_rolegrp.role_key   
             LEFT JOIN link_local.tsecure.dbo.pl_usr_role pl_usr_role (NOLOCK) ON pl_usr.usr_key = pl_usr_role.usr_key AND pl_usr_role.app_key = 1   
             LEFT JOIN link_local.tsecure.dbo.pl_role pl_role (NOLOCK) ON pl_usr_role.role_key = pl_role.role_key   
             WHERE pl_usr.usr_login = @c_username  
             AND (pl_role.role_name = 'IDS_SUPERVISOR' OR pl_rolegrp.role_name = 'IDS_SUPERVISOR')  )  
             */  
   SET @c_SQL = N' IF EXISTS(SELECT 1   
             FROM '+ @c_linksrvrname + '.' + @c_tsecurename + '.dbo.pl_usr pl_usr (NOLOCK)   
             LEFT JOIN '+ @c_linksrvrname + '.'+ @c_tsecurename + '.dbo.pl_grp_usr pl_grp_usr (NOLOCK) ON pl_usr.usr_key = pl_grp_usr.usr_key  
             LEFT JOIN '+ @c_linksrvrname + '.'+ @c_tsecurename + '.dbo.pl_grp_role pl_grp_role (NOLOCK) ON pl_grp_usr.grp_key = pl_grp_role.grp_key AND pl_grp_role.app_key = 1  
             LEFT JOIN '+ @c_linksrvrname + '.'+ @c_tsecurename + '.dbo.pl_role pl_rolegrp (NOLOCK) ON pl_grp_role.role_key = pl_rolegrp.role_key   
             LEFT JOIN '+ @c_linksrvrname + '.'+ @c_tsecurename + '.dbo.pl_usr_role pl_usr_role (NOLOCK) ON pl_usr.usr_key = pl_usr_role.usr_key AND pl_usr_role.app_key = 1   
             LEFT JOIN '+ @c_linksrvrname + '.'+ @c_tsecurename + '.dbo.pl_role pl_role (NOLOCK) ON pl_usr_role.role_key = pl_role.role_key   
             WHERE pl_usr.usr_login = ''' + @c_username + '''  
             AND (pl_role.role_name = ''IDS_SUPERVISOR'' OR pl_rolegrp.role_name = ''IDS_SUPERVISOR''))   
             BEGIN  
              SET @c_flag = ''Y''  
             END'  
               
     SET @c_ExecArguments = N'@c_flag  NVARCHAR(1) OUTPUT'    
       
     
    EXEC sp_ExecuteSql @c_SQL     
                     , @c_ExecArguments    
                     , @c_flag  OUTPUT       
  --IF @n_CNTRec >= 1    
  --/*CS01 End*/                          
  --BEGIN  
  -- SET @c_flag = 'Y'  
  --END  
    
  SET @n_err = @@ERROR  
    
  IF @n_err <> 0   
  BEGIN  
    SELECT @b_success = 0  
     SELECT @c_ErrMsg='NSQL'+CONVERT(NVARCHAR(5),@n_Err)+': Failed to access TSECURE. (isp_CheckSupervisorRole)'   
     RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012  
  END  
    
END  