if exists (SELECT * from dbo.sysobjects where id = object_id(N'[dbo].[ids_ScheduleConnections]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ids_ScheduleConnections]
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/*  5-Sep-2012  KHLim     "LIKE EXceed%" intead of "= EXceed WMS" (KH01)            */  

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
    
   insert user_connections (login_name, login_date, [Application])    
      select RTRIM(UserName),     
             getdate(),   
             'RDT'    
      from RDT.RdtMobRec (nolock)    
      where datediff(minute, editdate, getdate()) <= 120    
      group by UserName    
    
END    
    
    
    
  
