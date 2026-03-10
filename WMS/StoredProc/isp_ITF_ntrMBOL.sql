SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
  
/************************************************************************/  
/* Store Procedure:  isp_ITF_ntrMBOL                                    */  
/* Creation Date: 15-Jul-2016                                           */  
/* Copyright: LF                                                        */  
/* Written by: MCTang                                                   */  
/*                                                                      */  
/* Purpose:  Handling trigger points for MBOL's module.                 */  
/*           Including MBOL Header trigger points for Add&Update        */  
/*                                                                      */  
/* Output Parameters:  @b_Success                                       */  
/*                     @n_Err                                           */  
/*                     @c_ErrMsg                                        */  
/*                                                                      */  
/* Return Status:  @b_Success = 0 or 1                                  */  
/*                                                                      */  
/* Usage:  StorerConfig & Trigger Points verification & update on       */  
/*         configuration table - ITFTriggerConfig.                      */  
/*                                                                      */  
/* Called By:  Trigger/Store Procedure.                                 */  
/*             - ntrMBOLHeaderAdd                                       */  
/*             - ntrMBOLHeaderUpdate                                    */  
/*                                                                      */  
/* PVCS Version: 1.0                                                    */  
/*                                                                      */  
/* Version: 5.4                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/* Date         Author    Ver.  Purposes                                */  
/* 24-Jan-2017  TLTING01  1.1   SET ANSI NULLS Option                   */
/* 11-Apr-2018  MCTang    2.1   OTM add StorerConfig Check (MC01)       */
/* 04-Feb-2019  MCTang    2.2   Add GVTITF (MC02)                       */
/* 13-Mar-2019  YTKuek    2.3   Add GVTITF Event (YT01)                 */
/* 26-Apr-2019  MCTang    2.4   Add OTM MBLUPDOTM (MC03)                */
/* 29-Jan-2024  YTKuek    2.9   Add GVTITF LOGIGH (CY01)                */
/* 10-Jan-2025  YTKuek    3.0   Add GVTITF Trigger (YT02)               */
/* 09-Mar-2026  Michael   3.1   FCR-11043 New Trigger enhancement (ML01)*/
/************************************************************************/  
  
CREATE OR ALTER PROC isp_ITF_ntrMBOL
            @c_TriggerName          nvarchar(120)  
          , @c_SourceTable          nvarchar(60)  
          , @c_StorerKey            nvarchar(15)  
          , @c_MBOLKey              nvarchar(10)  
          , @b_ColumnsUpdated       VARBINARY(1000)             
          , @b_Success              int           OUTPUT  
          , @n_Err                  int           OUTPUT  
          , @c_ErrMsg               nvarchar(250) OUTPUT  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_NULLS OFF  
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   /********************************************************/  
   /* Variables Declaration & Initialization - (Start)     */  
   /********************************************************/  
   DECLARE @n_continue              int    
         , @n_StartTCnt             int     -- Holds the current transaction count  
  
   -- ITFTriggerConfig table  
   DECLARE @c_ConfigKey             nvarchar(30)  
         , @c_Tablename             nvarchar(30) 
         , @c_Tablename2            nvarchar(30)   --(YT01) 
         , @c_TablenameLOGIGH       NVARCHAR(30)  -- (CY01)
         , @c_RecordType            nvarchar(10)  
         , @c_RecordStatus          nvarchar(10)  
         , @c_sValue                nvarchar(10)  
         , @c_TargetTable           nvarchar(60)  
         , @c_StoredProc            nvarchar(200)  
         , @c_ConfigFacility        nvarchar(5)
         , @c_UpdatedColumns        NVARCHAR(250)      
         --ML01-S
         , @c_Authority             NVARCHAR(30)
         , @c_Option5               NVARCHAR(4000)
         , @c_SQL                   NVARCHAR(MAX)
         , @c_Key1                  NVARCHAR(10)
         , @c_Key2                  NVARCHAR(30)
         --ML01-E
  
   DECLARE @c_Status                nvarchar(10)  
         , @c_FinalizeFlag          NVARCHAR(1)   
  
   SET @n_StartTCnt = @@TRANCOUNT   
   SET @n_continue = 1   
   SET @b_success = 0   
   SET @n_Err = 0   
   SET @c_ErrMsg = ''                     
   /********************************************************/  
   /* Variables Declaration & Initialization - (End)       */  
   /********************************************************/  
  
   /*************************************************************************************/  
   /* Std - Verify Parameter variables, no values found, return to core program (Start) */  
   /*************************************************************************************/  
   IF (ISNULL(RTRIM(@c_TriggerName),'') = '') OR   
      (ISNULL(RTRIM(@c_SourceTable),'') = '') OR         
      (ISNULL(RTRIM(@c_MBOLKey),'') = '')  
   BEGIN  
      RETURN  
   END  
  
   IF (ISNULL(RTRIM(@c_TriggerName),'') <> 'ntrMBOLHeaderUpdate')  
   BEGIN  
      IF (ISNULL(RTRIM(@c_TriggerName),'') <> 'ntrMBOLHeaderAdd')  
      BEGIN  
         RETURN  
      END  
   END  
  
   IF (ISNULL(RTRIM(@c_SourceTable),'') <> 'MBOL')  
   BEGIN  
      RETURN  
   END  
   /*************************************************************************************/  
   /* Std - Verify Parameter variables, no values found, return to core program (End)   */  
   /*************************************************************************************/  
  
  
   /*************************************************************************************/  
   /* Std - Extract values for required variables (Start)                               */  
   /*************************************************************************************/  
   IF @n_continue = 1 OR @n_continue = 2  
   BEGIN  
      SELECT @c_Status        = ISNULL(RTRIM(Status),'')  
           , @c_FinalizeFlag  = ISNULL(RTRIM(FinalizeFlag),'')
      FROM   MBOL WITH (NOLOCK)   
      WHERE  MBOLKey = @c_MBOLKey  
   END   
   /*************************************************************************************/  
   /* Std - Extract values for required variables (End)                                 */  
   /*************************************************************************************/  
  
/********************************************/  
/* Main Program (Start)                     */  
/********************************************/  
   IF @n_continue = 1 OR @n_continue = 2  
   BEGIN  
      IF EXISTS ( SELECT 1 FROM ITFTriggerConfig WITH (NOLOCK)    
                  WHERE StorerKey   = @c_StorerKey   
                  AND   SourceTable = @c_SourceTable  
                  AND   sValue      = '1' )  
      BEGIN   
         DECLARE Cur_ITFTriggerConfig CURSOR LOCAL FAST_FORWARD READ_ONLY FOR   
         SELECT DISTINCT  ConfigKey  
                        , Facility  
                        , Tablename  
                        , RecordType  
                        , RecordStatus  
                        , sValue  
                        , TargetTable  
                        , StoredProc
                        , UpdatedColumns  
         FROM  ITFTriggerConfig WITH (NOLOCK)   
         WHERE StorerKey   = @c_StorerKey    
         AND   SourceTable = @c_SourceTable  
         AND   sValue      = '1'  
  
         OPEN Cur_ITFTriggerConfig  
         FETCH NEXT FROM Cur_ITFTriggerConfig INTO @c_ConfigKey, @c_ConfigFacility, @c_Tablename, @c_RecordType, @c_RecordStatus  
                                                         , @c_sValue, @c_TargetTable, @c_StoredProc, @c_UpdatedColumns   
  
         WHILE @@FETCH_STATUS <> -1  
         BEGIN 

            IF ISNULL(RTRIM(@c_UpdatedColumns), '') <> ''
            BEGIN
               IF NOT EXISTS(SELECT 1 FROM 
                             dbo.fnc_GetUpdatedColumns(@c_SourceTable, @b_ColumnsUpdated) 
                             WHERE COLUMN_NAME IN (
                                             SELECT ColValue 
                                             FROM dbo.fnc_DelimSplit(',', @c_UpdatedColumns)))
               BEGIN
                  --PRINT 'Not Exists, GET_NEXT_Record '
                  GOTO GET_NEXT_Record
               END 
            END
            ELSE
            BEGIN
               GOTO GET_NEXT_Record
            END
            
            SET @b_Success = 0
            
            IF ISNULL(RTRIM(@c_StoredProc),'') <> ''
            BEGIN
               SET @b_Success = 0 
               
               EXEC sys.sp_executesql @c_StoredProc, N'@c_MBOLKey NVARCHAR(10), @b_Success INT OUTPUT, @c_ErrNo INT OUTPUT, @c_ErrMsg NVARCHAR(215) OUTPUT',
                           @c_MBOLKey, 
                           @b_Success OUTPUT, 
                           @n_Err     OUTPUT, 
                           @c_ErrMsg  OUTPUT 
            END
            ELSE
            BEGIN
               IF (@c_RecordStatus <> '' AND @c_RecordStatus = @c_Status        AND UPPER(@c_UpdatedColumns) = 'STATUS') OR  
                  (@c_RecordStatus <> '' AND @c_RecordStatus = @c_FinalizeFlag AND UPPER(@c_UpdatedColumns) = 'FinalizeFlag' )  
               BEGIN 
                  SET @b_Success = 1
               END 
            END
             
            IF @b_Success = 1
            BEGIN
               --ML01-S
               IF ISNULL(@c_ConfigKey,'')<>'' AND @c_TargetTable IN ('TRANSMITLOG3', 'TRANSMITLOG2')
               BEGIN
                  SELECT @c_Authority = ''
                       , @c_Option5   = ''
                       , @c_SQL       = ''
                       , @c_Key1      = ''
                       , @c_Key2      = ''
   
                  SELECT @c_Authority = Authority
                       , @c_Option5   = Option5
                    FROM dbo.fnc_GetRight2('', @c_Storerkey, '', @c_ConfigKey)

                  IF @c_Authority = '1'
                  BEGIN
                     SET @c_SQL = dbo.fnc_GetParamValueFromString('@c_TLogKey1SQL', @c_Option5, '')
                     
                     IF ISNULL(@c_SQL,'')<>''
                     BEGIN
                        IF OBJECT_ID('tempdb..#TEMP_TRANSMITLOG') IS NULL
                           CREATE TABLE #TEMP_TRANSMITLOG (
                                SeqNo    INT IDENTITY(1,1) NOT NULL PRIMARY KEY
                              , Key1     NVARCHAR(10) NULL
                              , Key2     NVARCHAR(30) NULL
                           )
                        ELSE
                           TRUNCATE TABLE #TEMP_TRANSMITLOG

                        SET @c_SQL = N'INSERT INTO #TEMP_TRANSMITLOG (Key1, Key2) ' + @c_SQL

                        EXEC sys.sp_executesql @c_SQL, N'@c_TriggerName NVARCHAR(120), @c_SourceTable NVARCHAR(60), @c_Storerkey NVARCHAR(15), @c_MBOLKey NVARCHAR(10)'
                           , @c_TriggerName
                           , @c_SourceTable
                           , @c_StorerKey
                           , @c_MBOLKey

                        DECLARE CUR_TRANSMITLOG CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
                        SELECT Key1, Key2
                        FROM #TEMP_TRANSMITLOG
                        GROUP BY Key1, Key2
                        ORDER BY MIN(SeqNo)

                        OPEN CUR_TRANSMITLOG
                        FETCH NEXT FROM CUR_TRANSMITLOG INTO @c_Key1, @c_Key2

                        WHILE @@FETCH_STATUS = 0 AND @n_continue IN (1,2)
                        BEGIN
                           IF @c_TargetTable = 'TRANSMITLOG3'
                           BEGIN
                              EXEC ispGenTransmitLog3 @c_Tablename, @c_Key1, @c_Key2, @c_StorerKey, ''
                                                    , @b_success OUTPUT, @n_Err OUTPUT, @c_ErrMsg OUTPUT
                              IF @b_success <> 1
                              BEGIN
                                 SET @n_continue = 3
                                 SET @n_Err = 68003
                                 SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@n_Err,0)) +
                                                ': Insert into TRANSMITLOG3 Failed. (isp_ITF_ntrMBOL) ( SQLSvr MESSAGE = ' +
                                                ISNULL(LTRIM(RTRIM(@c_ErrMsg)),'') + ' ) '
                                 BREAK
                              END
                           END
                           ELSE IF @c_TargetTable = 'TRANSMITLOG2'
                           BEGIN
                              EXEC ispGenTransmitLog2 @c_Tablename, @c_Key1, @c_Key2, @c_StorerKey, ''
                                                    , @b_success OUTPUT, @n_Err OUTPUT, @c_ErrMsg OUTPUT
                              IF @b_success <> 1
                              BEGIN
                                 SET @n_continue = 3
                                 SET @n_Err = 68004
                                 SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@n_Err,0)) +
                                                ': Insert into TRANSMITLOG2 Failed. (isp_ITF_ntrMBOL) ( SQLSvr MESSAGE = ' +
                                                ISNULL(LTRIM(RTRIM(@c_ErrMsg)),'') + ' ) '
                                 BREAK
                              END
                           END
                     
                           FETCH NEXT FROM CUR_TRANSMITLOG INTO @c_Key1, @c_Key2
                        END
                        CLOSE CUR_TRANSMITLOG
                        DEALLOCATE CUR_TRANSMITLOG

                        IF @n_continue = 3
                           GOTO QUIT
                        GOTO GET_NEXT_Record
                     END
                  END
               END
               --ML01-E

               IF @c_TargetTable = 'TRANSMITLOG3'   
               BEGIN  
                  EXEC ispGenTransmitLog3 @c_Tablename, @c_MBOLKey, '', @c_StorerKey, ''  
                                          , @b_success OUTPUT  
                                          , @n_Err OUTPUT  
                                          , @c_ErrMsg OUTPUT  
                       
                  IF @b_success <> 1  
                  BEGIN  
                     SET @n_continue = 3  
                     SET @n_Err = 68001  
                     SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@n_Err,0)) +   
                                     ': Insert into TRANSMITLOG3 Failed. (isp_ITF_ntrMBOL) ( SQLSvr MESSAGE = ' +   
                                     ISNULL(LTRIM(RTRIM(@c_ErrMsg)),'') + ' ) '  
                     GOTO QUIT  
                  END   
               END -- IF @c_TargetTable = 'TRANSMITLOG3'   

               --(KT01) - Start
               IF @c_TargetTable = 'TRANSMITLOG2'   
               BEGIN  
                  EXEC ispGenTransmitLog2 @c_Tablename, @c_MBOLKey, '', @c_StorerKey, '' 
                                          , @b_success OUTPUT  
                                          , @n_Err OUTPUT  
                                          , @c_ErrMsg OUTPUT  
                       
                  IF @b_success <> 1  
                  BEGIN  
                     SET @n_continue = 3  
                     SET @n_Err = 68001  
                     SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@n_Err,0)) +   
                                     ': Insert into TRANSMITLOG2 Failed. (isp_ITF_ntrMBOL) ( SQLSvr MESSAGE = ' +   
                                     ISNULL(LTRIM(RTRIM(@c_ErrMsg)),'') + ' ) '  
                     GOTO QUIT  
                  END   
               END -- IF @c_TargetTable = 'TRANSMITLOG2'  
               --(KT01) - End               
            END
  
            GET_NEXT_Record:
            
            FETCH NEXT FROM Cur_ITFTriggerConfig INTO @c_ConfigKey, @c_ConfigFacility, @c_Tablename, @c_RecordType, @c_RecordStatus  
                                                            , @c_sValue, @c_TargetTable, @c_StoredProc, @c_UpdatedColumns   
         END -- WHILE @@FETCH_STATUS <> -1  
         CLOSE Cur_ITFTriggerConfig  
         DEALLOCATE Cur_ITFTriggerConfig  
      END -- IF EXISTS ( SELECT 1 FROM ITFTriggerConfig WITH (NOLOCK)   
   END -- IF @n_continue = 1 OR @n_continue = 2  


   /* Handle ITC.StorerKey='ALL' which not able to configure detail in ITFTriggerConfig */   
   IF @n_continue = 1 OR @n_continue = 2  
   BEGIN 

      /********************************************/  
      /* OTMITF (START)                           */  
      /********************************************/ 

      SET @c_Tablename2 = ''   --(MC03)

      IF EXISTS ( SELECT 1 FROM ITFTriggerConfig ITC WITH (NOLOCK)    
                  JOIN   StorerConfig STC WITH (NOLOCK)                                                          
                  ON    (STC.StorerKey   = @c_StorerKey AND STC.ConfigKey = 'OTMITF' AND STC.SValue = '1' AND STC.ConfigKey = ITC.ConfigKey)   
                  WHERE  ITC.StorerKey   = 'ALL'   
                  AND    ITC.SourceTable = @c_SourceTable  
                  AND    ITC.sValue      = '1' )  
      BEGIN
         IF ISNULL(RTRIM(@c_TriggerName),'') = 'ntrMBOLHeaderUpdate'
         BEGIN
            IF EXISTS(SELECT 1 FROM 
                      dbo.fnc_GetUpdatedColumns(@c_SourceTable, @b_ColumnsUpdated) 
                      WHERE COLUMN_NAME IN ('STATUS','FinalizeFlag'))
            BEGIN

               SET @b_Success = 0

               IF @c_Status = '9' 
               BEGIN
                  SET @c_TableName = 'MBOLSHPOTM'
                  SET @c_TableName2 = 'MBLUPDOTM'      --(MC03)  
                  SET @b_Success = 1
               END

               IF @b_Success = 1
               BEGIN
   	            IF EXISTS ( SELECT 1 FROM StorerConfig STC WITH (NOLOCK)                   --(MC01)
   	                        WHERE STC.StorerKey = @c_Storerkey 
                              AND   STC.ConfigKey = @c_Tablename
   	                        AND   STC.SValue    = '1' )
                  BEGIN
                     EXEC ispGenOTMLog @c_Tablename, @c_MBOLKey, @c_Status, @c_StorerKey, ''  
                                     , @b_success   OUTPUT  
                                     , @n_err       OUTPUT  
                                     , @c_errmsg    OUTPUT 

                     IF @b_success <> 1
                     BEGIN
                        SET @n_continue = 3
                        GOTO QUIT 
                     END
                  END

                  --(MC03) - S
                  IF @c_TableName2 <> ''  
                  BEGIN  
                   IF EXISTS ( SELECT 1 FROM StorerConfig STC WITH (NOLOCK)   
                               WHERE STC.StorerKey = @c_Storerkey   
                               AND   STC.ConfigKey = @c_TableName2  
                               AND   STC.SValue    = '1' )  
                     BEGIN  
                        EXEC ispGenOTMLog @c_TableName2, @c_MBOLKey, @c_Status, @c_StorerKey, ''    
                                        , @b_success   OUTPUT    
                                        , @n_err       OUTPUT    
                                        , @c_errmsg    OUTPUT   
  
                        IF @b_success <> 1  
                        BEGIN  
                           SET @n_continue = 3  
                           GOTO QUIT   
                        END  
                     END  
                  END 
                  --(MC03) - E

               END -- IF @b_Success = 1
            END -- ColValue IN ('STATUS','SOSTATUS')
         END -- IF (ISNULL(RTRIM(@c_TriggerName),'') = 'ntrOrderHeaderUpdate')  
      END -- IF EXISTS ( SELECT 1 FROM ITFTriggerConfig WITH (NOLOCK)    
      /********************************************/  
      /* OTMITF (End)                             */  
      /********************************************/

      /********************************************/  
      /* GVTITF (START)                           */  
      /********************************************/ 
      --(MC02) - S
      IF EXISTS ( SELECT 1 FROM StorerConfig STC WITH (NOLOCK) 
                  WHERE STC.StorerKey = @c_Storerkey   
                  AND   STC.ConfigKey = 'GVTITF'  
                  AND   STC.SValue    = '1' )                       
      BEGIN
         IF ISNULL(RTRIM(@c_TriggerName),'') = 'ntrMBOLHeaderUpdate'
         BEGIN
            IF EXISTS(SELECT 1 FROM 
                      dbo.fnc_GetUpdatedColumns(@c_SourceTable, @b_ColumnsUpdated) 
                      WHERE COLUMN_NAME IN ('STATUS','FinalizeFlag'))
            BEGIN

               SET @b_Success = 0
               SET @c_TableName = ''   --(YT01)
               SET @c_TableName2 = ''  --(YT01)
               SET @c_TablenameLOGIGH = ''  --(CY01)

               IF @c_Status = '9' 
               BEGIN
                  SET @c_TableName = 'GVTMBOLSHP'
                  SET @c_TableName2 = 'GVTEMBLSHP' --(YT01)
                  SET @c_TablenameLOGIGH = 'GVTMBOLSHPLOGIGH' --(CY01)
                  SET @b_Success = 1
               END

               IF @b_Success = 1
               BEGIN
   	            IF EXISTS ( SELECT 1 FROM StorerConfig STC WITH (NOLOCK)            
   	                        WHERE STC.StorerKey = @c_Storerkey 
                              AND   STC.ConfigKey = @c_Tablename
   	                        AND   STC.SValue    = '1' )
                  BEGIN
                     EXEC ispGenGVTLog @c_Tablename, @c_MBOLKey, @c_Status, @c_StorerKey, ''  
                                     , @b_success   OUTPUT  
                                     , @n_err       OUTPUT  
                                     , @c_errmsg    OUTPUT 

                     IF @b_success <> 1
                     BEGIN
                        SET @n_continue = 3
                        GOTO QUIT 
                     END
                  END

                  --(YT01)-S
   	            IF EXISTS ( SELECT 1 FROM StorerConfig STC WITH (NOLOCK)            
   	                        WHERE STC.StorerKey = @c_Storerkey 
                              AND   STC.ConfigKey = @c_TableName2
   	                        AND   STC.SValue    = '1' )
                  BEGIN
                     EXEC ispGenGVTLog @c_TableName2, @c_MBOLKey, @c_Status, @c_StorerKey, ''  
                                     , @b_success   OUTPUT  
                                     , @n_err       OUTPUT  
                                     , @c_errmsg    OUTPUT 

                     IF @b_success <> 1
                     BEGIN
                        SET @n_continue = 3
                        GOTO QUIT 
                     END
                  END
                  --(YT01)-E

                  --(CY01)-S
   	            IF EXISTS ( SELECT 1 FROM StorerConfig STC WITH (NOLOCK)            
   	                        WHERE STC.StorerKey = @c_Storerkey 
                              AND   STC.ConfigKey = @c_TablenameLOGIGH
   	                        AND   STC.SValue    = '1' )
                  BEGIN
                     EXEC ispGenGVTLog @c_TablenameLOGIGH, @c_MBOLKey, @c_Status, @c_StorerKey, ''  
                                     , @b_success   OUTPUT  
                                     , @n_err       OUTPUT  
                                     , @c_errmsg    OUTPUT 

                     IF @b_success <> 1
                     BEGIN
                        SET @n_continue = 3
                        GOTO QUIT 
                     END
                  END
                  --(CY01)-E

                  --(YT02)-S
   	            IF EXISTS ( SELECT 1 FROM StorerConfig STC WITH (NOLOCK)            
   	                        WHERE STC.StorerKey = @c_Storerkey 
                              AND   STC.ConfigKey = 'GVTMBOLSHPLG'
   	                        AND   STC.SValue    = '1' )
                  BEGIN
                     EXEC ispGenGVTLog 'GVTMBOLSHPLG', @c_MBOLKey, @c_Status, @c_StorerKey, ''  
                                     , @b_success   OUTPUT  
                                     , @n_err       OUTPUT  
                                     , @c_errmsg    OUTPUT 

                     IF @b_success <> 1
                     BEGIN
                        SET @n_continue = 3
                        GOTO QUIT 
                     END
                  END
                  --(YT02)-E
               END -- IF @b_Success = 1
            END -- ColValue IN ('STATUS','SOSTATUS')
         END -- IF (ISNULL(RTRIM(@c_TriggerName),'') = 'ntrOrderHeaderUpdate')  
      END -- IF EXISTS ( SELECT 1 FROM ITFTriggerConfig WITH (NOLOCK)    
      --(MC02) - E
      /********************************************/  
      /* GVTITF (End)                             */  
      /********************************************/

   END -- IF @n_continue = 1 OR @n_continue = 2 

/********************************************/  
/* Main Program (End)                       */  
/********************************************/  
  
/********************************************/  
/* Std - Error Handling (Start)             */  
/********************************************/  
QUIT:  
  
   WHILE @@TRANCOUNT < @n_StartTCnt  
      BEGIN TRAN  
  
   IF @n_continue=3  -- Error Occured - Process And Return  
   BEGIN  
      SELECT @b_success = 0  
      IF @@TRANCOUNT > @n_StartTCnt  
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
      EXECUTE dbo.nsp_logerror @n_Err, @c_ErrMsg, 'isp_ITF_ntrMBOL'  
  
      RAISERROR (@c_ErrMsg, 16, 1) WITH SETERROR  
      RETURN  
   END  
   ELSE  
   BEGIN  
      SELECT @b_success = 1  
      WHILE @@TRANCOUNT > @n_StartTCnt  
      BEGIN  
         COMMIT TRAN  
      END  
      RETURN  
   END  
/********************************************/  
/* Std - Error Handling (End)               */  
/********************************************/  
END -- procedure  
GO

GRANT EXECUTE ON isp_ITF_ntrMBOL TO NSQL
GO
