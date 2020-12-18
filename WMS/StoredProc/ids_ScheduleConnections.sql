if exists (SELECT * from dbo.sysobjects where id = object_id(N'[dbo].[ids_ScheduleConnections]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ids_ScheduleConnections]
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
/***************************************************************************/ 
/* Object Name: ids_ScheduleConnections                                    */
/* Modification History:                                                   */  
/*                                                                         */  
/* Called By:  Exceed                                                      */
/*                                                                         */
/* PVCS Version: 1.0                                                       */
/*                                                                         */
/* Version: 5.4                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Date         Author    Ver.  Purposes                                   */
/* 05-Sep-2012  KHLim     LIKE EXceed%" intead of "= EXceed WMS" (KH01)    */  
/***************************************************************************/ 
CREATE PROC ids_ScheduleConnections    
      @c_WMSDB NVARCHAR(10)   
AS    
BEGIN    
   SET NOCOUNT ON    
    
   DELETE USER_CONNECTIONS     
      WHERE DateDiff(day, login_date, GetDate()) > 120    
    
   INSERT USER_CONNECTIONS (LOGIN_NAME, LOGIN_DATE, [APPLICATION], HOSTNAME)    
      SELECT DISTINCT LOGINAME, getdate(), 'WMS', Hostname    
      FROM MASTER.DBO.SYSPROCESSES (NOLOCK)    
      where db_name(dbid) = @c_WMSDB     
        AND program_name LIKE 'EXceed%'   --KH01    
    
   INSERT USER_CONNECTIONS (login_name, login_date, [Application])    
      SELECT RTRIM(UserName),     
             getdate(),   
             'RDT'    
      FROM RDT.RdtMobRec (nolock)    
      WHERE datediff(minute, editdate, getdate()) <= 120    
      GROUP BY UserName    
    
END  
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

GRANT EXECUTE ON ids_ScheduleConnections TO nSQL
GO    
    
    
  
