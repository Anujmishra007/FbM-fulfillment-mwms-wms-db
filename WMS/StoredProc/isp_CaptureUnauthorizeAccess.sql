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
WHERE  sd.name = @s_DBName            
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
      'GenericTCPSocketListener_WCS'    , 'QCSvc'  ,'Microsoft JDBC Driver for SQL Server', 'IgniteMonitor',      
      'RDT_PrintZPL', 'FTSP','LEAF_OMS', 'Managed Backup'    
         
      )            
and sp.program_name NOT like 'SQLAgent %'            
and sp.program_name NOT LIKE 'SQL Query Analyzer%'            
and sp.program_name NOT LIKE 'SQL Server Profiler%'          
and sp.program_name NOT LIKE 'Microsoft SQL Server Management Studio%'          
and sp.program_name NOT LIKE 'QCmd_WS_Out_%'       
and sp.program_name NOT LIKE '%QCSvc_%'         
and sp.program_name NOT LIKE '%DTBSvc_%'        
and sp.program_name NOT LIKE 'Red Gate Software%'        
and sp.program_name NOT LIKE '%QueueCommander_WMS.exe%'    
and sp.program_name NOT LIKE 'Inter Machine Link%'       
AND ( sp.loginame = 'sa' and sp.program_name <> '' )          
AND  ( sp.loginame not in ('QCmdUser','DataTransferBridgeUser','hyperionuser','ePODUser','FileExporter', 'AppDyn') )    
    
    
     
/*    
INSERT INTO TraceInfo  (TraceName,TimeIn,TimeOut,TotalTime,Step1,Step2,Step3,Step4,Step5    
,Col1,Col2,Col3,Col4,Col5)     
SELECT DISTINCT 'BrioBQY', GetDate() AS AddDate, s.login_time, '',s.session_id, s.program_name , s.host_name     
, s.login_name, c.client_net_address, DB_NAME(s.database_id) as database_name,client_tcp_port,    
    c.net_transport, c.auth_scheme,''    
           
--SELECT s.session_id, s.login_name, DB_NAME(s.database_id) as database_name,     
--    s.host_name, s.program_name, c.client_net_address, client_tcp_port,    
--    c.net_transport, c.auth_scheme, s.login_time    
FROM sys.dm_exec_sessions s    
INNER JOIN sys.dm_exec_connections c  ON s.session_id = c.session_id     
WHERE   s.program_name not in (            
      'Microsoft SQL Server',            
      'EXceed WMS',        
      'dxscheduler',            
      'DTS Designer',            
      'Microsoft (r) Windows Script Host',            
      'jTDS',         
  --    'MS SQLEM',             
 --     'Brio Enterprise Client',             
 --     'NIKE Pick&Pack',             
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
      'RDT_Print',  'INTERNAL_WMSAPI_IML', 'BondDPC', 'SQLServerCEIP',    
      'RDTTrace',       
      'SQL Server Log Shipping',      
      'WMS_DPC_Listener',            
      'WMS PDA',          
  --    'Microsoft? Query',      
      'GenericTCPSocketListener_WCS'    , 'QCSvc'  ,'Microsoft JDBC Driver for SQL Server', 'IgniteMonitor',      
      'RDT_PrintZPL', 'FTSP','LEAF_OMS' ,'eComWMS', 'Managed Backup'  
      )            
and s.program_name NOT like 'SQLAgent %'            
and s.program_name NOT LIKE 'SQL Query Analyzer%'            
and s.program_name NOT LIKE 'SQL Server Profiler%'          
and s.program_name NOT LIKE 'Microsoft SQL Server Management Studio%'         
and s.program_name NOT LIKE 'SqlDbx%'          
and s.program_name NOT LIKE 'QCmd_WS_Out_%'       
and s.program_name NOT LIKE '%QCSvc_%'         
and s.program_name NOT LIKE '%DTBSvc_%'        
and s.program_name NOT LIKE 'Red Gate Software%'        
and s.program_name NOT LIKE '%QueueCommander_WMS.exe%'       
and s.program_name NOT LIKE '%DataImporter%'    
and s.program_name NOT LIKE 'Socket_Spooler%'       
and s.program_name NOT LIKE 'DatabaseMail%'        
and s.program_name NOT LIKE 'Inter Machine Link%'     
AND  ( S.login_name not in ( 'iml''QCmdUser','DataTransferBridgeUser', 'ePODUser','LEAFUser','FileExporter','LEAFAPIUSER','sn_usr','dts', 'AppDyn') )    
AND  c.client_net_address <> '172.21.8.241'    
ORDER BY s.session_id    
*/      
    
 INSERT INTO wms_sysprocess ( currenttime, login_time , last_batch,  spid ,  [program_name], hostname,    
 loginame,net_address,[DB_Name] ,   Eventinfo, lastwaittype )    
     
SELECT DISTINCT GetDate() AS AddDate, s.login_time,  s.last_request_start_time,    
 s.session_id, s.program_name , s.host_name     
, s.login_name, c.client_net_address, DB_NAME(s.database_id) as database_name, t.text  , 'BrioBQY'    
         
           
--SELECT s.session_id, s.login_name, DB_NAME(s.database_id) as database_name,     
--    s.host_name, s.program_name, c.client_net_address, client_tcp_port,    
--    c.net_transport, c.auth_scheme, s.login_time    
FROM sys.dm_exec_sessions s    
INNER JOIN sys.dm_exec_connections c  ON s.session_id = c.session_id     
CROSS APPLY sys.dm_exec_sql_text(c.most_recent_sql_handle) AS t    
WHERE   s.program_name not in (            
      'Microsoft SQL Server',            
      'EXceed WMS',        
      'dxscheduler',            
      'DTS Designer',            
      'Microsoft (r) Windows Script Host',            
      'jTDS',         
  --    'MS SQLEM',             
 --     'Brio Enterprise Client',             
 --     'NIKE Pick&Pack',             
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
      'RDT_Print',  'INTERNAL_WMSAPI_IML', 'BondDPC', 'SQLServerCEIP',    
      'RDTTrace',       
      'SQL Server Log Shipping',      
      'WMS_DPC_Listener',            
      'WMS PDA',          
  --    'Microsoft? Query',      
      'GenericTCPSocketListener_WCS'    , 'QCSvc'  ,'Microsoft JDBC Driver for SQL Server', 'IgniteMonitor',      
      'RDT_PrintZPL', 'FTSP','LEAF_OMS' ,'eComWMS', 'Managed Backup'     
      )            
and s.program_name NOT like 'SQLAgent %'            
and s.program_name NOT LIKE 'SQL Query Analyzer%'            
and s.program_name NOT LIKE 'SQL Server Profiler%'          
and s.program_name NOT LIKE 'Microsoft SQL Server Management Studio%'         
and s.program_name NOT LIKE 'SqlDbx%'          
and s.program_name NOT LIKE 'QCmd_WS_Out_%'       
and s.program_name NOT LIKE '%QCSvc_%'         
and s.program_name NOT LIKE '%DTBSvc_%'        
and s.program_name NOT LIKE 'Red Gate Software%'        
and s.program_name NOT LIKE '%QueueCommander_WMS.exe%'       
and s.program_name NOT LIKE '%DataImporter%'    
and s.program_name NOT LIKE 'Socket_Spooler%'       
and s.program_name NOT LIKE 'DatabaseMail%'     
and s.program_name NOT LIKE 'Inter Machine Link%'    
AND  ( S.login_name not in ( 'iml''QCmdUser','DataTransferBridgeUser',   'ePODUser','LEAFUser','FileExporter','LEAFAPIUSER','sn_usr','dts', 'AppDyn') )    
AND  c.client_net_address <> '172.21.8.241'    
ORDER BY s.session_id    
     
GO


GRANT EXECUTE ON [dbo].[isp_CaptureUnauthorizeAccess] TO nSQL 
GO
