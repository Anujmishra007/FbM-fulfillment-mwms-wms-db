IF EXISTS (SELECT name FROM dbo.sysobjects WHERE name = 'isp_archiveTable3' AND type = 'P')
   DROP PROC dbo.isp_archiveTable3
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/          
/* Store Procedure:  isp_archiveTable3                                  */          
/* Creation Date: 18-Aug-2010                                           */          
/* Copyright: IDS                                                       */          
/* Written by: TLTING                                                   */          
/*                                                                      */          
/* Purpose:  Archive records with ArchiveCop column for more than       */        
/*           by specific condition                                      */          
/*           Specify TargetDB and Target tablename                      */          
/*                                                                      */          
/* Input Parameters:  @cSourceDB     - Exceed DB                        */          
/*                    @cArchiveDB    - Archive DB                       */          
/*                    @cSourceTableName                                 */           
/*                    @cTargetTableName                                 */         
/*                    @cKeyName      - Main Table Key (eg.Pickheaderkey)*/          
/*                    @cKey1         - 1st Table Key (eg.PickSlipNo)    */          
/*                    @cKey2         - 2nd Table Key (eg.PickSlipNo)    */          
/*                    @cCondition    - Filter Criteria/etc              */          
/*                                                                      */          
/* Usage:  Archive older records with the same batch of tables into the */          
/*         Archive DB at one time. Maximum two (2) tables at one time.  */          
/*                                                                      */          
/* Called By:  Set under Scheduler Jobs.                                */          
/*                                                                      */          
/* PVCS Version: 1.0                                                    */          
/*                                                                      */          
/* Version: 5.4                                                         */          
/*                                                                      */          
/* Data Modifications:                                                  */          
/*                                                                      */          
/* Updates:                                                             */          
/* Date         Author    Purposes                                      */     
/* 7-Oct-2020   TLTING01  Variable length                               */    
/* 14-Nov-2020  TLTING02  Skip update archivecop                        */   
/* 01-Feb-2021  TLTING03  Bug fix                                       */  
/************************************************************************/          
           
CREATE  PROC [dbo].[isp_archiveTable3]            
    @cSourceDB VarCHAR(128) ,    -- KHLim01        
    @cArchiveDB VarCHAR(128) ,   -- KHLim01        
    @cSourceTableName VarCHAR(128) ,   -- KHLim01        
    @cTargetTableName VarCHAR(128) ,  -- KHLim01        
    @cKeyName VarCHAR(128) ,     -- KHLim01        
    @cKeyName1 VarCHAR(128) ,    -- KHLim01        
    @cKeyName2 VarCHAR(128) ,    -- KHLim01        
    @cKeyName3 VarCHAR(128) ,    -- KHLim01        
    @cCondition VarCHAR(4000)         
AS          
BEGIN          
   SET NOCOUNT ON           
   SET ANSI_NULLS OFF          
   SET QUOTED_IDENTIFIER OFF           
   SET CONCAT_NULL_YIELDS_NULL OFF          
        
   DECLARE @b_success INT,           
            @n_err INT,         
            @c_errmsg CHAR(250),        
            @local_n_err INT,        
            @local_c_errmsg CHAR(250),        
            @n_archive_table_records INT,                    
            @n_archive_table1_records INT,        
            @n_archive_table2_records INT,          
            @n_archive_table3_records INT,        
            @n_cnt INT             
          
   DECLARE  @b_debug INT           
   SELECT   @b_debug = 0          
   DECLARE  @n_starttcnt INT , -- Holds the current transaction count        
            @n_continue INT ,           
            @cExecStatements NVARCHAR(2000)            
   SELECT   @n_starttcnt = @@TRANCOUNT ,           
            @n_continue = 1 ,           
            @b_success = 0 ,           
            @n_err = 0 ,           
            @c_errmsg = '' ,           
            @cExecStatements = ''            
         
   DECLARE @c_KeyValue nvarchar(50), -- TLTING01        
           @c_SQLWhere nvarchar(2000),        
           @c_KeyColumn nvarchar(50)        
           
           
           
   IF (@n_continue = 1 OR @n_continue = 2) AND ISNULL(@cSourceTableName, '') <> ''        
   BEGIN            
   --   select @b_success = 1          
   --   EXEC nsp_BUILD_ARCHIVE_TABLE           
   --   @cSourceDB,           
   --   @cArchiveDB,           
   --   @cSourceTableName,          
   --   @b_success OUTPUT,           
   --   @n_err OUTPUT,           
   --   @c_errmsg OUTPUT          
   --   IF not @b_success = 1          
   --   BEGIN          
   --      SELECT @n_continue = 3          
   --   END          
   --   IF (@b_debug = 1)          
   --   BEGIN          
   --      print 'building alter table string for POD...'          
   --   END          
      EXECUTE nspBuildAlterTableString2          
         @cArchiveDB,          
         @cSourceTableName,        
         @cTargetTableName,          
         @b_success OUTPUT,          
         @n_err OUTPUT,           
         @c_errmsg OUTPUT          
      IF not @b_success = 1          
      BEGIN          
         SELECT @n_continue = 3          
      END                
   END        
     
   IF @cCondition is NULL  
      SET @cCondition = ''  
     
   IF @cCondition = ''  
   BEGIN  
      SET @cCondition = 'ArchiveCop is NULL '  
   END  
   ELSE  
   BEGIN  
      SET @cCondition = @cCondition + ' AND ( ArchiveCop is NULL OR ArchiveCop <> ''9'' ) '    -- TLTING03
   END  
     
   IF (@n_continue = 1 OR @n_continue = 2)        
   BEGIN        
      SET @cExecStatements = N'DECLARE C_ITEM CURSOR FAST_FORWARD READ_ONLY FOR '          
                              + 'SELECT DISTINCT ' + LTRIM(RTRIM(@cSourceTableName)) + '.' + LTRIM(RTRIM(@cKeyName))            
                              + ' FROM ' + LTRIM(RTRIM(@cSourceTableName)) + ' WITH (NOLOCK) '           
                              + ' WHERE ' + @cCondition              
              
   END         
      if (@b_debug =1 )        
      begin        
         Print @cExecStatements        
      end        
   EXEC sp_ExecuteSql @cExecStatements            
          
   OPEN C_ITEM          
   FETCH NEXT FROM C_ITEM INTO @c_KeyValue           
          
   WHILE @@FETCH_STATUS <> -1           
   BEGIN          
               
    IF (@n_continue = 1 OR @n_continue = 2) AND ISNULL(@cSourceTableName, '') <> ''        
    BEGIN        
       if (@b_debug =1 )        
       begin        
            print @c_SQLWhere        
          print 'building Update ArchiveCop for ' + @cSourceTableName        
       end        
       select @b_success = 1        
           
         SET @cExecStatements = N'UPDATE ' + LTRIM(RTRIM(@cSourceTableName)) + ' '            
                              + ' SET ArchiveCop = ''9'' '         
                              + ' WHERE ' +  LTRIM(RTRIM(@cSourceTableName)) + '.' + LTRIM(RTRIM(@cKeyName))         
                              + ' =  RTRIM(@c_KeyValue)  '             
         BEGIN TRAN        
                
      
         EXEC sp_ExecuteSql @cExecStatements, N'@c_KeyValue Nvarchar(50)' , @c_KeyValue         -- TLTING01     
         SELECT @local_n_err = @@ERROR, @n_cnt = @@ROWCOUNT          
         IF @local_n_err <> 0          
         BEGIN           
          SELECT @n_continue = 3          
          SELECT @local_n_err = 73702          
          SELECT @local_c_errmsg = CONVERT(char(5),@local_n_err)          
          SELECT @local_c_errmsg =          
             ': Update of Archivecop failed - ' + @cSourceTableName + '. (isp_archiveTable3) ( ' +          
             ' SQLSvr MESSAGE = ' + dbo.fnc_LTrim(dbo.fnc_RTrim(@local_c_errmsg)) + ')'          
          ROLLBACK TRAN           
         END         
         ELSE        
         BEGIN        
            COMMIT TRAN         
         END           
      END                  
              
              
      FETCH NEXT FROM C_ITEM INTO @c_KeyValue           
   END -- WHILE @@FETCH_STATUS <> -1           
   CLOSE C_ITEM          
   DEALLOCATE C_ITEM           
         
 IF (@n_continue = 1 OR @n_continue = 2) AND ISNULL(@cSourceTableName, '') <> ''        
 BEGIN        
      if (@b_debug =1 )        
      begin        
         print @c_SQLWhere        
         print 'building insert for ' + @cSourceTableName        
      end        
      select @b_success = 1        
      EXEC nsp_BUILD_INSERT2            
         @cArchiveDB,           
         @cSourceTableName,        
         @cTargetTableName,       
         1,          
         @b_success OUTPUT,           
         @n_err OUTPUT,           
         @c_errmsg OUTPUT          
      if not @b_success = 1        
      begin        
         select @n_continue = 3        
      end        
   END         
            
   /* #INCLUDE <SPTPA01_2.SQL> */            
   IF @n_continue=3  -- Error Occured - Process And Return            
   BEGIN            
      SELECT @b_success = 0            
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_starttcnt            
      BEGIN            
         ROLLBACK TRAN            
      END            
      ELSE            
      BEGIN            
         WHILE @@TRANCOUNT > @n_starttcnt            
         BEGIN            
            COMMIT TRAN            
         END            
      END            
      EXECUTE dbo.nsp_logerror @n_err, @c_errmsg, 'isp_archiveTable3'            
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR -- SQL 2012 (Jay01)           
      RETURN            
   END            
   ELSE            
   BEGIN            
      SELECT @b_success = 1            
      WHILE @@TRANCOUNT > @n_starttcnt            
      BEGIN            COMMIT TRAN            
      END            
      RETURN            
   END            
END -- procedure 
GO

