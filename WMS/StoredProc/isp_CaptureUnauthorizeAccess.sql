IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_CaptureUnauthorizeAccess]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_CaptureUnauthorizeAccess]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/  
/* Stored Procedure: isp_CaptureUnauthorizeAccess                       */  
/* Creation Date: 04-Jun-2002                                           */  
/* Copyright: IDS                                                       */  
/* Written by:                                                          */  
/*                                                                      */  
/* Purpose:                                                             */  
/*                                                                      */  
/* Called By:                                                           */  
/*                                                                      */  
/* PVCS Version: 1.3                                                    */  
/*                                                                      */  
/* Version: 5.4                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author        Purposes                                  */  
/* 25-Oct-2012            1.0 Initial Version                           */
/* 07-Nov-2016  Ting      1.1 Review the program name                   */
/************************************************************************/  
CREATE PROC [dbo].[isp_CaptureUnauthorizeAccess]       
   @s_DBName NVARCHAR(20)      
AS       
SET NOCOUNT ON   
SET QUOTED_IDENTIFIER OFF   
SET ANSI_NULLS OFF   
SET CONCAT_NULL_YIELDS_NULL OFF     

IF DatePart(hour,getdate()) = 3  -- only run this during off peak (3am)
   DELETE UnauthorizeAccess      
   WHERE  DateDiff(day, AddDate, GETDATE()) > 7       
    
INSERT INTO [UnauthorizeAccess]    
           ([AddDate]    
           ,[SPID]    
           ,[ProgramName]    
           ,[HostName]    
           ,[Login_Time]    
           ,[Login_ID]  
           ,[Net_Address] )    
SELECT distinct       
       GetDate() AS AddDate,       
       sp.spid,       
       sp.program_name,       
       sp.hostname,       
       sp.Login_Time,     
       sp.loginame,  
       SubString(sp.net_address, 1, 2) + '-' +     
       SubString(sp.net_address, 3, 2) + '-' +   
       SubString(sp.net_address, 5, 2) + '-' +   
       SubString(sp.net_address, 7, 2) + '-' +   
       SubString(sp.net_address, 9, 2) + '-' +   
       SubString(sp.net_address, 11, 2)         
FROM master..sysprocesses sp WITH (nolock)      
JOIN master..sysdatabases sd WITH (NOLOCK) ON sp.dbid = sd.dbid     
WHERE sd.name = @s_DBName      
and sp.program_name not in (      
      'Microsoft SQL Server',      
      'EXceed WMS',  
      'dxscheduler',      
      'DTS Designer',      
      'Microsoft (r) Windows Script Host',      
      'jTDS',   
      'MS SQLEM',       
      'Brio Enterprise Client',       
      'NIKE Pick&Pack',       
      'EXceed',     
      'EXceed 6.0',      --KH01
      'Exceed 7.0'  ,
      'Zeus',       
      'DTS Designer',       
      '.Net SqlClient Data Provider',
      'GenericWebServiceHost',
      'EXCEL2WMS',
      'LFLigthLink',
      'PowerBuilder',
      'RDT',
      'RDT Print Server',
      'RDT_Print', 
      'RDTTrace', 
      'SQL Server Log Shipping',
      'WMS_DPC_Listener',      
      'WMS PDA',    
      'Microsoft? Query',
      'GenericTCPSocketListener_WCS'     
      )      
and sp.program_name NOT like 'SQLAgent - TSQL JobStep%'      
and sp.program_name NOT LIKE 'SQL Query Analyzer%'      
and sp.program_name NOT LIKE 'SQL Server Profiler%'    
and sp.program_name NOT LIKE 'Microsoft SQL Server Management Studio%'    
and sp.program_name NOT LIKE 'QCmd_WS_Out_%'  
and sp.program_name NOT LIKE '%QueueCommander_WMS.exe%'
or ( sp.loginame = 'sa' and sp.program_name <> '' )   
GO


GRANT EXECUTE ON [dbo].[isp_CaptureUnauthorizeAccess] TO nSQL 
GO
