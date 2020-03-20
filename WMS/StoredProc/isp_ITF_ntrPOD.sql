IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[isp_ITF_ntrPOD]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[isp_ITF_ntrPOD]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/  
/* Store Procedure:  isp_ITF_ntrPOD                                     */  
/* Creation Date: 12-Aug-2014                                           */  
/* Copyright: LF                                                        */  
/* Written by: MCTang                                                   */  
/*                                                                      */  
/* Purpose:  Handling trigger points for POD's module.                  */  
/*           Including POD trigger points for Add & Update.             */  
/*                                                                      */  
/* Output Parameters:  @b_Success                                       */  
/*                     @n_err                                           */  
/*                     @c_errmsg                                        */  
/*                                                                      */  
/* Return Status:  @b_Success = 0 or 1                                  */  
/*                                                                      */  
/* Usage:  StorerConfig & Trigger Points verification & update on       */  
/*         configuration table - ITFTriggerConfig.                      */  
/*                                                                      */  
/* Called By:  Trigger/Store Procedure.                                 */  
/*             - ntrPODAdd                                              */  
/*             - ntrPODUpdate                                           */  
/*                                                                      */  
/* PVCS Version: 1.0                                                    */  
/*                                                                      */  
/* Version: 5.4                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/* Date        Author   Ver.  Purposes                                  */  
/*01-Oct-2015  KTLow    1.0   Add Insert Transmitlog2 (KT01)            */  
/*24-Jan-2017  TLTING01 1.1   SET ANSI NULLS Option                     */
/************************************************************************/  
  
CREATE PROC [dbo].[isp_ITF_ntrPOD]  
            @c_TriggerName          nvarchar(120)  
          , @c_SourceTable          nvarchar(60)  
          , @c_StorerKey            nvarchar(15)
          , @c_MBOLKey              nvarchar(10)  
          , @c_MBOLLineNumber       nvarchar(5)  
          , @b_ColumnsUpdated       VARBINARY(1000)
          , @b_Success              int           OUTPUT  
          , @n_err                  int           OUTPUT  
          , @c_errmsg               nvarchar(250) OUTPUT  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_NULLS OFF      --tlting
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
/********************************************************/  
/* Variables Declaration & Initialization - (Start)     */  
/********************************************************/  
   DECLARE @n_Continue              int    
         , @n_StartTCnt             int     -- Holds the current transaction count  
  
   -- ITFTriggerConfig table  
   DECLARE @c_ConfigKey             nvarchar(30)  
         , @c_Tablename             nvarchar(30)  
         , @c_RecordType            nvarchar(10)  
         , @c_RecordStatus          nvarchar(10)  
         , @c_sValue                nvarchar(10)  
         , @c_TargetTable           nvarchar(60)  
         , @c_StoredProc            nvarchar(200)  
         , @c_ConfigFacility        nvarchar(5)
         , @c_UpdatedColumns        NVARCHAR(250)      
  
   -- ORDERS table  
   DECLARE @c_OrderKey              nvarchar(10)  
         , @c_Status                nvarchar(10)  
         , @c_Key1                  NVARCHAR(10)
         , @c_Key2                  NVARCHAR(5)
         , @c_FinalizeFlag          NVARCHAR(1)   
  
   SET @n_StartTCnt = @@TRANCOUNT   
   SET @n_Continue = 1   
   SET @b_success = 0   
   SET @n_err = 0   
   SET @c_errmsg = ''   
/********************************************************/  
/* Variables Declaration & Initialization - (End)       */  
/********************************************************/  
  
/*************************************************************************************/  
/* Std - Verify Parameter variables, no values found, return to core program (Start) */  
/*************************************************************************************/  
   IF (ISNULL(RTRIM(@c_TriggerName),'') = '') OR   
      (ISNULL(RTRIM(@c_SourceTable),'') = '') OR         
      (ISNULL(RTRIM(@c_MBOLKey),'') = '')     OR
      (ISNULL(RTRIM(@c_MBOLLineNumber),'') = '')          
   BEGIN  
      RETURN  
   END  
  
   IF (ISNULL(RTRIM(@c_TriggerName),'') <> 'ntrPODUpdate')  
   BEGIN  
      IF (ISNULL(RTRIM(@c_TriggerName),'') <> 'ntrPODAdd')  
      BEGIN  
         RETURN  
      END  
   END  
  
   IF (ISNULL(RTRIM(@c_SourceTable),'') <> 'POD')  
   BEGIN  
      RETURN  
   END  
/*************************************************************************************/  
/* Std - Verify Parameter variables, no values found, return to core program (End)   */  
/*************************************************************************************/  
  
  
/*************************************************************************************/  
/* Std - Extract values for required variables (Start)                               */  
/*************************************************************************************/  
   IF @n_Continue = 1 OR @n_Continue = 2  
   BEGIN  
      SELECT @c_OrderKey         = ISNULL(RTRIM(POD.OrderKey),'')  
           , @c_Status           = ISNULL(RTRIM(POD.Status),'')   
           , @c_FinalizeFlag     = ISNULL(RTRIM(POD.FinalizeFlag),'')
      FROM  POD WITH (NOLOCK)   
      WHERE POD.MBOLKey          = @c_MBOLKey  
      AND   POD.MBOLLineNumber   = @c_MBOLLineNumber
   END   
/*************************************************************************************/  
/* Std - Extract values for required variables (End)                                 */  
/*************************************************************************************/  
  
/********************************************/  
/* Main Program (Start)                     */  
/********************************************/  
   IF @n_Continue = 1 OR @n_Continue = 2  
   BEGIN  
      IF EXISTS ( SELECT 1 
                  FROM  ITFTriggerConfig WITH (NOLOCK)    
                  WHERE StorerKey   = @c_StorerKey   
                  AND   SourceTable = @c_SourceTable  
                  AND   sValue      = '1' )  
      BEGIN   
         DECLARE Cur_ITFTriggerConfig_Order CURSOR LOCAL FAST_FORWARD READ_ONLY FOR   
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
  
         OPEN Cur_ITFTriggerConfig_Order  
         FETCH NEXT FROM Cur_ITFTriggerConfig_Order INTO   @c_ConfigKey
                                                         , @c_ConfigFacility
                                                         , @c_Tablename
                                                         , @c_RecordType
                                                         , @c_RecordStatus  
                                                         , @c_sValue
                                                         , @c_TargetTable
                                                         , @c_StoredProc
                                                         , @c_UpdatedColumns   
  
         WHILE @@FETCH_STATUS <> -1  
         BEGIN 
            --PRINT '@c_ConfigKey: ' + @c_ConfigKey
            --PRINT '@c_UpdatedColumns: ' + @c_UpdatedColumns  
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
            
            SET @b_Success = 0

            IF ISNULL(RTRIM(@c_StoredProc),'') <> ''
            BEGIN
               EXEC sys.sp_executesql @c_StoredProc, N'@c_OrderKey NVARCHAR(10), @b_Success INT OUTPUT, @c_ErrNo INT OUTPUT, @c_ErrMsg NVARCHAR(215) OUTPUT',
                           @c_OrderKey, 
                           @b_Success OUTPUT, 
                           @n_err     OUTPUT, 
                           @c_errmsg  OUTPUT 
            END
            ELSE
            BEGIN
               IF (@c_RecordStatus <> '' AND (@c_RecordStatus = @c_Status)) OR
                  (@c_RecordStatus <> '' AND (@c_RecordStatus = @c_FinalizeFlag))
               BEGIN 
                  SET @b_Success = 1
               END 
            END

            IF @b_Success = 1
            BEGIN
               /*************************************************************************************/
               /* Records Insertion into selected TransmitLog table with StorerKey - (Start)        */
               /*************************************************************************************/
               IF @c_TargetTable = 'TRANSMITLOG3'
               BEGIN
                  EXEC ispGenTransmitLog3 @c_Tablename, @c_OrderKey, '', @c_StorerKey, ''
                                        , @b_success OUTPUT
                                        , @n_Err OUTPUT
                                        , @c_ErrMsg OUTPUT
                     
                  IF @b_success <> 1
                  BEGIN
                     SET @n_Continue = 3
                     SET @n_Err = 68001
                     SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@n_Err,0)) + 
                                     ': Insert into TRANSMITLOG3 Failed. (isp_ITF_ntrPOD) ( SQLSvr MESSAGE = ' + 
                                     ISNULL(LTRIM(RTRIM(@c_ErrMsg)),'') + ' ) '
                     GOTO QUIT
                  END 
               END -- IF @c_TargetTable = 'TRANSMITLOG3'

               --(KT01) - Start
               IF @c_TargetTable = 'TRANSMITLOG2'
               BEGIN
                  EXEC ispGenTransmitLog2 @c_Tablename, @c_OrderKey, @c_Status, @c_StorerKey, ''
                                        , @b_success OUTPUT
                                        , @n_Err OUTPUT
                                        , @c_ErrMsg OUTPUT
                     
                  IF @b_success <> 1
                  BEGIN
                     SET @n_Continue = 3
                     SET @n_Err = 68001
                     SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@n_Err,0)) + 
                                     ': Insert into TRANSMITLOG2 Failed. (isp_ITF_ntrPOD) ( SQLSvr MESSAGE = ' + 
                                     ISNULL(LTRIM(RTRIM(@c_ErrMsg)),'') + ' ) '
                     GOTO QUIT
                  END 
               END -- IF @c_TargetTable = 'TRANSMITLOG2'
               --(KT01) - End
               /*************************************************************************************/
               /* Records Insertion into selected TransmitLog table with StorerKey - (End)          */
               /*************************************************************************************/
            END  --IF @b_Success = 1
  
            GET_NEXT_Record:
            
            FETCH NEXT FROM Cur_ITFTriggerConfig_Order INTO   @c_ConfigKey
                                                            , @c_ConfigFacility
                                                            , @c_Tablename
                                                            , @c_RecordType
                                                            , @c_RecordStatus  
                                                            , @c_sValue
                                                            , @c_TargetTable
                                                            , @c_StoredProc
                                                            , @c_UpdatedColumns    
         END -- WHILE @@FETCH_STATUS <> -1  
         CLOSE Cur_ITFTriggerConfig_Order  
         DEALLOCATE Cur_ITFTriggerConfig_Order  
      END -- IF EXISTS @c_SourceTable     
   END -- IF @n_Continue = 1 OR @n_Continue = 2  
/********************************************/  
/* Main Program (End)                       */  
/********************************************/  
  
/********************************************/  
/* Std - Error Handling (Start)             */  
/********************************************/  
QUIT:  
  
   WHILE @@TRANCOUNT < @n_StartTCnt  
      BEGIN TRAN  
  
   IF @n_Continue=3  -- Error Occured - Process And Return  
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
      EXECUTE dbo.nsp_logerror @n_err, @c_errmsg, 'isp_ITF_ntrPOD'  
  
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR  
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


GRANT EXECUTE ON dbo.isp_ITF_ntrPOD TO NSQL
GO

