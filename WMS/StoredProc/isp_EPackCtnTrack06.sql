IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_EPackCtnTrack06]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_EPackCtnTrack06]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
    
/************************************************************************/        
/* Trigger: isp_EPackCtnTrack06                                         */        
/* Creation Date: 12-OCT-2020                                           */        
/* Copyright: LF Logistics                                              */        
/* Written by: Wan                                                      */        
/*                                                                      */        
/* Purpose: WMS-15244 - [CN] NIKE_O2_Ecom_packing_RFID_CR               */        
/*        :                                                             */        
/* Called By: n_cst_packcarton_ecom                                     */        
/*          : ue_getcartontrackno                                       */        
/*        :                                                             */        
/* PVCS Version: 1.0                                                    */        
/*                                                                      */        
/* Version: 7.0                                                         */        
/*                                                                      */        
/* Data Modifications:                                                  */        
/*                                                                      */        
/* Updates:                                                             */        
/* Date        Author   Ver   Purposes                                  */        
/* 12-OCT-2020 Wan      1.0   Created                                   */         
/************************************************************************/        
CREATE PROC [dbo].[isp_EPackCtnTrack06]        
         @c_PickSlipNo  NVARCHAR(10)         
      ,  @n_CartonNo    INT        
      ,  @c_CTNTrackNo  NVARCHAR(40)         OUTPUT        
      ,  @b_Success     INT = 0              OUTPUT   -- 0:Fail, 1:Success 2:Success with Track # is lock        
      ,  @n_err         INT = 0              OUTPUT         
      ,  @c_errmsg      NVARCHAR(255) = ''   OUTPUT         
AS        
BEGIN        
   SET NOCOUNT ON        
   SET ANSI_NULLS OFF        
   SET QUOTED_IDENTIFIER OFF        
   SET CONCAT_NULL_YIELDS_NULL OFF        
        
   DECLARE @n_StartTCnt       INT         = @@TRANCOUNT         
         , @n_Continue        INT         = 1  
     
         , @c_TableName       NVARCHAR(10)= ''
         , @c_CartonNo        NVARCHAR(10)= ''
         , @c_Orderkey        NVARCHAR(10)= ''      
         , @c_Storerkey       NVARCHAR(15)= '' 
         , @c_TaskBatchNo     NVARCHAR(10)= '' 
         
         , @c_Command         NVARCHAR(1000)=''
         , @c_TransmitlogKey  NVARCHAR(10)  =''
         , @c_IP              VARCHAR(20)   =''
         , @c_Port            VARCHAR(10)   =''
         , @n_ThreadPerAcct   INT           =0
         , @n_MilisecondDelay INT           =0
         , @c_APP_DB_Name     VARCHAR(10)   =''
         , @n_ThreadPerStream INT           =0
         , @c_IniFilePath     NVARCHAR(200) =''
         , @c_DataStream      VARCHAR(10)   ='4577'
        
   SET @b_Success  = 1        
   SET @n_err      = 0        
   SET @c_errmsg   = ''        
        
   WHILE @@TRANCOUNT > 0         
   BEGIN        
      COMMIT TRAN        
   END        
        
   SET @c_Orderkey = ''        
   SELECT @c_Orderkey = Orderkey         
         ,@c_Storerkey= Storerkey
         ,@c_TaskBatchNo = TaskBatchNo 
   FROM PACKHEADER WITH (NOLOCK)        
   WHERE PickSlipNo = @c_PickSlipNo        
        
   IF @c_Orderkey = ''        
   BEGIN 
      SET @n_continue = 3        
      SET @n_err = 60010          
      SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Orderkey is required to get Tracking #. (isp_EPackCtnTrack06)'         
      GOTO QUIT_SP                      
   END    
   
   IF NOT EXISTS (SELECT 1 
                  FROM PACKTASKDETAIL  PTD WITH (NOLOCK)   
                  LEFT JOIN PACKDETAIL PD  WITH (NOLOCK) ON (PTD.PickSlipNo = PD.PickSlipNo)   
                                                         AND(PTD.Storerkey = PD.Storerkey)  
                                                         AND(PTD.Sku = PD.Sku)  
                  WHERE PTD.TaskBatchNo = @c_TaskBatchNo  
                  AND   PTD.Orderkey = @c_Orderkey    
                  GROUP  BY PTD.Orderkey  
                           ,PTD.Storerkey  
                           ,PTD.Sku  
                           ,PTD.QtyAllocated 
                  HAVING PTD.QtyAllocated -  ISNULL(SUM(PD.Qty),0) > 0  
                 )            
   BEGIN
      GOTO QUIT_SP  
   END

   SEND_ITF: -- Send ITF to get Tracking # for Next CartonNo
   BEGIN TRAN
   SET @c_Tablename = 'WSTRACKLOG'
   SET @c_CartonNo = CONVERT(NVARCHAR(5), @n_CartonNo + 1)
   
   SET @c_TransmitlogKey = ''
   EXECUTE nspg_getkey  
     'TransmitlogKey2'  
     , 10  
     , @c_TransmitlogKey   OUTPUT  
     , @b_success          OUTPUT  
     , @n_err              OUTPUT  
     , @c_errmsg           OUTPUT  
  
   IF NOT @b_success = 1  
   BEGIN  
      SET @n_continue = 3  
      SET @c_errmsg = ERROR_MESSAGE()
      SET @n_Err=60020   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
      SET @c_errmsg = 'NSQL' + CONVERT(char(5),@n_err)   
                        + ': Unable to Obtain transmitlogkey. (ispGenTransmitLog2) ( SQLSvr MESSAGE='   
                          + @c_errmsg + ' ) ' 
      GOTO QUIT_SP                     
   END  

   INSERT INTO TRANSMITLOG2 (transmitlogkey, tablename, key1, key2, key3, transmitflag, TransmitBatch)  
   VALUES (@c_TransmitlogKey, @c_TableName, @c_OrderKey, @c_CartonNo, @c_StorerKey, '0', '') 
   
   IF @@ERROR <> 0          
   BEGIN          
      SET @n_continue = 3  
      SET @c_errmsg = ERROR_MESSAGE()        
      SET @n_err = 60030          
      SET @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@n_err,0)) +           
                    + ': Insert into TRANSMITLOG2 Failed. (isp_EPackCtnTrack06) '
                    + '( SQLSvr MESSAGE = ' + @c_errmsg + ' ) '          
      GOTO QUIT_SP          
   END 
   
   --EXEC ispGenTransmitLog2 @c_Tablename, @c_OrderKey, @c_CartonNo, @c_StorerKey, ''          
   --                        , @b_success OUTPUT          
   --                        , @n_err OUTPUT          
   --                        , @c_errmsg OUTPUT          
                               
   --IF @b_success <> 1          
   --BEGIN          
   --   SET @n_continue = 3          
   --   SET @n_err = 60020          
   --   SET @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@n_err,0)) +           
   --                 + ': Insert into TRANSMITLOG2 Failed. (isp_EPackCtnTrack06) '
   --                 + '( SQLSvr MESSAGE = ' + @c_errmsg + ' ) '          
   --   GOTO QUIT_SP          
   --END 
   
   --SET @c_TransmitlogKey = ''
         
   --SELECT TOP 1 @c_TransmitlogKey = t.transmitlogkey
   --FROM TRANSMITLOG2 AS t WITH(NOLOCK)
   --WHERE t.tablename = @c_TableName
   --AND t.key1 = @c_OrderKey
   --AND t.key2 = @c_CartonNo 
   --AND t.key3 = @c_StorerKey 
   --AND t.transmitflag = '0'
   --ORDER BY t.transmitlogkey DESC
         
   --IF @c_TransmitlogKey <> ''
   --BEGIN
      SELECT @c_Command = StoredProcName + ',@c_TransmitlogKey=''' + @c_TransmitlogKey + ''' ' 
            ,@c_IP = IP
            ,@c_Port = Port
            ,@n_ThreadPerAcct = ThreadPerAcct
            ,@n_MilisecondDelay = MilisecondDelay 
            ,@c_APP_DB_Name = App_DB_Name--TargetDB      
            ,@c_IniFilePath = IniFilePath                
            ,@n_ThreadPerStream = ThreadPerStream        
      FROM  QCmd_TransmitlogConfig WITH (NOLOCK)  
      WHERE DataStream = @c_DataStream 
         AND TableName = @c_TableName  
         AND StorerKey = @c_StorerKey

      BEGIN TRY    
         EXEC isp_QCmd_SubmitTaskToQCommander     
               @cTaskType        = 'T'-- D=By Datastream, T=Transmitlog, O=Others           
            ,  @cStorerKey       = @c_StorerKey                                                
            ,  @cDataStream      = @c_DataStream                                                         
            ,  @cCmdType         = 'SQL'                                                      
            ,  @cCommand         = @c_Command                                                  
            ,  @cTransmitlogKey  = @c_TransmitlogKey                                             
            ,  @nThreadPerAcct   = @n_ThreadPerAcct                                                    
            ,  @nThreadPerStream = @n_ThreadPerStream                                                          
            ,  @nMilisecondDelay = @n_MilisecondDelay                                                          
            ,  @nSeq             = 1                           
            ,  @cIP              = @c_IP                                             
            ,  @cPORT            = @c_PORT                                                    
            ,  @cIniFilePath     = @c_IniFilePath           
            ,  @cAPPDBName       = @c_APP_DB_Name                                                   
            ,  @bSuccess         = @b_Success      OUTPUT                                     
            ,  @nErr             = @n_Err          OUTPUT      
            ,  @cErrMsg          = @c_ErrMsg       OUTPUT 
            ,  @nPriority        = 2                                                    
      END TRY    
      BEGIN CATCH  
         SET @n_Continue=3 
         SET @n_err = 60040   
         SET @c_ErrMsg = ERROR_MESSAGE()
         SET @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@n_err,0)) +           
                    + ': Error Executing isp_QCmd_SubmitTaskToQCommander. (isp_EPackCtnTrack06) '
                    + '( SQLSvr MESSAGE = ' + @c_errmsg + ' ) '    
         GOTO QUIT_SP 
      END CATCH 
   
      IF @n_Err <> 0 AND ISNULL(@c_ErrMsg,'') <> ''    
      BEGIN
      	SET @n_Continue=3 
         SET @n_err = 60050   
         SET @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@n_err,0)) +           
                    + ': ' + @c_errmsg + '. (isp_EPackCtnTrack06) '
         GOTO QUIT_SP     
      END                 
   --END         
        
   WHILE @@TRANCOUNT > 0        
   BEGIN        
      COMMIT TRAN        
   END        
        
   QUIT_SP:        
        
   IF @n_Continue=3  -- Error Occured - Process And Return        
   BEGIN        
      SET @b_Success = 0        
      IF @@TRANCOUNT > 0  
      BEGIN   
         ROLLBACK TRAN        
      END  
      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'isp_EPackCtnTrack06'        
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012        
   END        
        
   WHILE @@TRANCOUNT < @n_StartTCnt        
   BEGIN        
      BEGIN TRAN        
   END        
END -- procedure 
GO
GRANT EXECUTE ON [dbo].[isp_EPackCtnTrack06] TO nSQL 
GO
