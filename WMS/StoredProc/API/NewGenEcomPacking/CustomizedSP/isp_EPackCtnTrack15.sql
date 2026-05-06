SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
    
/************************************************************************/        
/* Trigger: isp_EPackCtnTrack15                                         */        
/* Creation Date: 2025-12-04                                            */        
/* Copyright: LF Logistics                                              */        
/* Written by: Mingle                                                   */        
/*                                                                      */        
/* Purpose: WMS-19152 - CN BELIV ECOM PACKING trigger point             */        
/*          FCR-8269 based on isp_EPackCtnTrack09                       */      
/* Called By: n_cst_packcarton_ecom                                     */        
/*          : ue_getcartontrackno                                       */        
/*        :                                                             */        
/* PVCS Version: 1.6                                                    */        
/*                                                                      */        
/* Version: 7.0                                                         */        
/*                                                                      */        
/* Data Modifications:                                                  */        
/*                                                                      */        
/* Updates:                                                             */        
/* Date         Author  Purposes                                        */        
/* 15-Dec-2025   Sean   FCR-8269 - tracking no refresh in the UI        */
/* 06-Jan-2026   Sean02 FCR-8269 - fix duplicate get from               */
/*                                      transmitlog2 or ispAsgnTNo2     */
/* 11-Feb-2026   Sean03 FCR-8269 - fix error message                    */
/************************************************************************/        
CREATE OR ALTER PROC [dbo].[isp_EPackCtnTrack15]    
         @b_Debug       INT          = 0 
      ,  @c_PickSlipNo  NVARCHAR(10)         
      ,  @n_CartonNo    INT
      ,  @b_CCTVREFRESHTRACKNO  INT  = 0              -- Sean
      ,  @b_CloseCarton  INT  = 0                      -- Sean
      ,  @b_FetchNextCarton  INT  = 0                 -- Sean03
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
     
         , @c_TableName       NVARCHAR(15)= ''
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
         , @c_APP_DB_Name     VARCHAR(30)   =''    
         , @n_ThreadPerStream INT           =0
         , @c_IniFilePath     NVARCHAR(200) =''
         , @c_DataStream      VARCHAR(10)   ='6157'
         , @b_SuccessOld      INT   
         , @c_UpdateCT        NVARCHAR(1) = 'N'  
         , @n_RowRef          BIGINT   
         , @c_Facility        NVARCHAR(5)    --WL01
         , @c_SValue          NVARCHAR(50)   --WL01
         , @c_Option1         NVARCHAR(50) = ''   --WL01
         , @c_Option2         NVARCHAR(50) = ''   --WL01
         , @c_Option3         NVARCHAR(50) = ''   --WL01
         , @c_Option4         NVARCHAR(50) = ''   --WL01
         , @c_Option5         NVARCHAR(4000) = '' --WL01
         , @c_ECOMPlatform    NVARCHAR(20) = ''   --WL02
         , @c_ECPlatform_JSON NVARCHAR(MAX) = ''   --WL02
         , @c_TL2KeyPrefix    NVARCHAR(MAX) = ''   --WL03
         , @c_Key1Prefix      NVARCHAR(20) = ''   --WL03
         , @c_Key2Prefix      NVARCHAR(20) = ''   --WL03
         , @c_Key3Prefix      NVARCHAR(20) = ''   --WL03
         , @c_Shipperkey      NVARCHAR(15) = ''   --NJOW02
         , @c_SkipGetMultiCartonTrack NVARCHAR(1) = 'N' --NJOW02
 
   SET @b_Success  = 1        
   SET @n_err      = 0        
   SET @c_errmsg   = ''        
        
   WHILE @@TRANCOUNT > 0         
   BEGIN        
      COMMIT TRAN        
   END        

   IF @b_Debug = 1
   BEGIN
      PRINT '--- isp_EPackCtnTrack15 Start ---'
   END
        
   SET @c_Orderkey = ''    
   SET @c_CTNTrackNo = ''   --WL04
   
   --WL01 S
   SELECT @c_Orderkey      = PACKHEADER.Orderkey         
         ,@c_Storerkey     = PACKHEADER.Storerkey
         ,@c_TaskBatchNo   = PACKHEADER.TaskBatchNo 
         ,@c_Facility      = ORDERS.Facility
         ,@c_ECOMPlatform  = ORDERS.ECOM_Platform   --WL02
         ,@c_ShipperKey    = ORDERS.Shipperkey --NJOW02
   FROM PACKHEADER WITH (NOLOCK)    
   JOIN ORDERS WITH (NOLOCK) ON ORDERS.OrderKey = PACKHEADER.OrderKey
   WHERE PickSlipNo = @c_PickSlipNo  
   --WL01 E
        
   IF @c_Orderkey = ''        
   BEGIN 
      SET @n_continue = 3        
      SET @n_err = 60010          
      SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Orderkey is required to get Tracking #. (isp_EPackCtnTrack15)'         
      GOTO QUIT_SP                      
   END   
   
   --WL01 S
   EXEC nspGetRight  
      @c_Facility          -- facility  
   ,  @c_Storerkey         -- Storerkey  
   ,  NULL                 -- Sku  
   ,  'EPackCtnTrackNo_SP' -- Configkey  
   ,  @b_Success                 OUTPUT   
   ,  @c_SValue                  OUTPUT   
   ,  @n_Err                     OUTPUT   
   ,  @c_ErrMsg                  OUTPUT 
   ,  @c_Option1                 OUTPUT
   ,  @c_Option2                 OUTPUT
   ,  @c_Option3                 OUTPUT
   ,  @c_Option4                 OUTPUT
   ,  @c_Option5                 OUTPUT

   IF @b_success <> 1  
   BEGIN  
      SET @n_continue = 3  
      SET @n_err = 60014   
      SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Error Executing nspGetRight. (isp_EPackCtnTrack15)'   
                  + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '   
      GOTO QUIT_SP  
   END 
   --WL01 E
   
   --NJOW02
   IF EXISTS(SELECT 1
             FROM CODELKUP CL (NOLOCK)
             WHERE CL.ListName = 'EP_CPNT'
             AND CL.Storerkey = @c_Storerkey
             AND CL.Short = @c_ECOMPlatform
             AND CL.Long = @c_ShipperKey)
   BEGIN
      SET @c_SkipGetMultiCartonTrack = 'Y'
   END
   
   --Get TrackingNo from Orders Header since Storerconfig ValidateTrackNo = '1' if CartonNo = 1 AND PackInfo is not exists
   IF NOT EXISTS (SELECT 1
                  FROM PACKINFO PIF (NOLOCK)
                  WHERE PIF.PickSlipNo = @c_PickSlipNo
                  AND PIF.CartonNo = @n_CartonNo) AND @n_CartonNo = 1
   BEGIN
      SELECT @c_CTNTrackNo = OH.TrackingNo
      FROM ORDERS OH (NOLOCK)
      WHERE OH.OrderKey = @c_Orderkey
   END

   If @b_CCTVREFRESHTRACKNO = 1 and @b_FetchNextCarton = 1
   BEGIN
      GOTO SEND_ITF  
   END

   IF NOT EXISTS (SELECT 1
                  FROM PACKINFO PIF (NOLOCK)
                  WHERE PIF.PickSlipNo = @c_PickSlipNo
                  AND PIF.CartonNo = @n_CartonNo) AND @n_CartonNo > 1 
                  AND @c_SkipGetMultiCartonTrack <> 'Y'  --NJOW02
   BEGIN
      SELECT TOP 1 @n_RowRef = CT.RowRef
                 , @c_CTNTrackNo = CT.TrackingNo
      FROM CARTONTRACK CT (NOLOCK)
      WHERE CT.LabelNo = @c_Orderkey
      AND CT.CarrierRef2 <> 'GET'
      AND CT.CarrierRef1 = @c_Orderkey + CAST(@n_CartonNo AS NVARCHAR)
      ORDER BY CT.AddDate

      IF ISNULL(@n_RowRef,0) > 0
      BEGIN
         SET @c_UpdateCT = 'Y'
      END
      ELSE
      BEGIN 
         --NJOW01
         SET @n_continue = 3  
         SET @n_err = 60015   
         SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Unable find tracking no for current carton# ' + CAST(@n_CartonNo AS NVARCHAR) + ' (isp_EPackCtnTrack15)'   
                  + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '                     
      END
   END

   IF ISNULL(@c_CTNTrackNo,'') <> ''
   BEGIN
      INSERT INTO PACKINFO 
               (  PickSlipNo
               ,  CartonNo
               ,  [Weight]
               ,  [Cube]
               ,  Height
               ,  [Length]
               ,  Width 
               ,  TrackingNo
               )
      VALUES(  @c_PickSlipNo
            ,  @n_CartonNo
            ,  0.00
            ,  0.00
            ,  0.00
            ,  0.00
            ,  0.00  
            ,  @c_CTNTrackNo
            )	
	   
      SET @n_err = @@ERROR

      IF @n_err <> 0
      BEGIN
         SET @n_continue = 3
         SET @n_err = 60015  
         SET @c_errmsg='NSQL'+CONVERT(CHAR(5),@n_err)+': Error Insert PACKINFO Table. (isp_EPackCtnTrack15)' 
                           + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) ' 
         GOTO QUIT_SP
      END

      SET @b_Success = 2   --Tell ECOM Packing to refresh Packinfo, do not insert PackInfo again
      SET @b_SuccessOld = @b_Success

      IF @c_UpdateCT = 'Y' AND ISNULL(@c_CTNTrackNo,'') <> ''
      BEGIN
         UPDATE dbo.CartonTrack
         SET CarrierRef2 = 'GET'
         WHERE RowRef = @n_RowRef
      END	 
   END

   --WL05 S
   --Next Gen ECOM Packing stamp Orders.Trackingno -> Packinfo.Trackingno on every closed carton
   IF EXISTS ( SELECT 1
               FROM PackInfo PIF (NOLOCK)
               WHERE PIF.PickSlipNo = @c_PickSlipNo
               AND   PIF.CartonNo = @n_CartonNo
               AND   ( ISNULL(PIF.TrackingNo, '') = '' or  (@b_CCTVREFRESHTRACKNO = 1 and @b_CloseCarton = 1)
                       OR PIF.TrackingNo IN ( SELECT TrackingNo
                                              FROM PackInfo WITH (NOLOCK)
                                              WHERE PickSlipNo = @c_PickSlipNo AND CartonNo = 1 )))
               AND @n_CartonNo > 1   --WL04
               AND @c_SkipGetMultiCartonTrack <> 'Y'  --NJOW02                                
   --WL05 E
   BEGIN
      SET @n_RowRef = 0 --NJOW01
      SET @c_CTNTrackNo = ''   --WL05
      
      SELECT TOP 1 @n_RowRef = CT.RowRef
                 , @c_CTNTrackNo = CT.TrackingNo
      FROM CartonTrack CT (NOLOCK)
      WHERE CT.LabelNo = @c_Orderkey
      --AND CT.CarrierRef2 = 'GET'
      AND   CT.CarrierRef1 = @c_Orderkey + CAST(@n_CartonNo AS NVARCHAR)
      ORDER BY CT.AddDate

      --Update Packinfo.Trackingno to blank if @c_CTNTrackNo is blank
      UPDATE dbo.PackInfo
      SET TrackingNo = @c_CTNTrackNo
      WHERE CartonNo = @n_CartonNo AND PickSlipNo = @c_PickSlipNo

      IF @n_RowRef > 0  --NJOW01
      BEGIN
         --NJOW01
         UPDATE dbo.CartonTrack
         SET CarrierRef2 = 'GET'
         WHERE RowRef = @n_RowRef            
      END
      ELSE
      BEGIN
      	 --NJOW01
         SET @n_continue = 3  
         SET @n_err = 60016   
         SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Unable find tracking no for current carton# ' + CAST(@n_CartonNo AS NVARCHAR) + ' (isp_EPackCtnTrack15)'   
                  + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '   
                  
      END
   END

   --Prevent get trackingno for next carton if this is the last carton
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

   -- new logic
   If @b_CCTVREFRESHTRACKNO = 1 and @b_CloseCarton = 1 -- close curren carton
   BEGIN
      GOTO QUIT_SP  
   END
   
   SEND_ITF: -- Send ITF to get Tracking # for Next CartonNo 
   IF @n_continue IN(1,2) AND @c_SkipGetMultiCartonTrack <> 'Y'  --NJOW02
   BEGIN
      BEGIN TRAN
      
      SET @c_Tablename = ''
      SET @c_DataStream = ''
      
      SELECT @c_Tablename = dbo.fnc_GetParamValueFromString('@c_Tablename', @c_Option5, '') 
      SELECT @c_DataStream = dbo.fnc_GetParamValueFromString('@c_DataStream', @c_Option5, '')  
      
      IF ISNULL(@c_Tablename,'') = '' AND ISNULL(@c_DataStream,'') = ''
      BEGIN
         SELECT @c_ECPlatform_JSON = dbo.fnc_GetParamValueFromString('@c_ECPlatform_JSON', @c_Option5, '')  
         
         IF ISNULL(TRIM(@c_ECPlatform_JSON),'') <> ''
         BEGIN
            DECLARE @T TABLE (
                 ECOM_Platform   NVARCHAR(100) NULL
               , Tablename       NVARCHAR(100) NULL
               , Datastream      NVARCHAR(100) NULL
            )
         
            INSERT INTO @T
            SELECT ECOM_Platform      
                 , Tablename
                 , Datastream          
            FROM
               OPENJSON(@c_ECPlatform_JSON)
               WITH (
               ECOM_Platform  NVARCHAR(100) '$.ECOM_Platform'
             , Tablename      NVARCHAR(100) '$.Tablename'
             , Datastream     NVARCHAR(100) '$.Datastream'
            )
            WHERE ECOM_Platform = @c_ECOMPlatform
         
            SELECT TOP 1 @c_TableName  = T.Tablename
                       , @c_DataStream = T.Datastream
            FROM @T T
         END
      END
      
      --WL03 S
      SET @c_TL2KeyPrefix = ''
      SELECT @c_TL2KeyPrefix = dbo.fnc_GetParamValueFromString('@c_TL2KeyPrefix', @c_Option5, '')  
      
      IF ISJSON(@c_TL2KeyPrefix) = 1
      BEGIN
         DECLARE @TL2 TABLE
         (
            [Column] NVARCHAR(10)  NULL
          , Prefix   NVARCHAR(100) NULL
         )
      
         INSERT INTO @TL2
         SELECT [Column]
              , Prefix
         FROM
            OPENJSON(@c_TL2KeyPrefix)
            WITH ([Column] NVARCHAR(10)  '$.Column'
                , Prefix   NVARCHAR(100) '$.Prefix')
      
         SELECT @c_Key1Prefix = CAST(T.Prefix AS NVARCHAR) FROM @TL2 T WHERE T.[Column] = 'Key1'
         SELECT @c_Key2Prefix = CAST(T.Prefix AS NVARCHAR) FROM @TL2 T WHERE T.[Column] = 'Key2'
         SELECT @c_Key3Prefix = CAST(T.Prefix AS NVARCHAR) FROM @TL2 T WHERE T.[Column] = 'Key3'
      END
      --WL03 E
      
      IF ISNULL(@c_Tablename, '') = ''
         SET @c_Tablename = 'WSCRPKADDCN' 
      
      IF ISNULL(@c_DataStream, '') = ''
         SET @c_DataStream = '6157' 
      --WL02 E
      
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
         SET @c_errmsg = 'NSQL' + CONVERT(CHAR(5),@n_err)   
                           + ': Unable to Obtain transmitlogkey. (ispGenTransmitLog2) ( SQLSvr MESSAGE='   
                             + @c_errmsg + ' ) ' 
         GOTO QUIT_SP                  
      END  

      -- origin logic
      If @b_CCTVREFRESHTRACKNO = 0
      BEGIN
         SET @c_CartonNo = CONVERT(NVARCHAR(5), @n_CartonNo + 1)
      END

      If @b_CCTVREFRESHTRACKNO = 1 and @n_CartonNo > 1
      BEGIN
         SET @c_CartonNo = CONVERT(NVARCHAR(5), @n_CartonNo)
      END

      INSERT INTO TRANSMITLOG2 (transmitlogkey, tablename, key1, key2, key3, transmitflag, transmitbatch)
      VALUES (@c_TransmitlogKey, @c_TableName
            , CASE WHEN TRIM(ISNULL(@c_Key1Prefix, '')) = '' 
                   THEN TRIM(@c_Orderkey)
                   ELSE TRIM(ISNULL(@c_Key1Prefix, '')) + TRIM(@c_Orderkey) END    --WL03
            , CASE WHEN TRIM(ISNULL(@c_Key2Prefix, '')) = '' 
                   THEN TRIM(@c_CartonNo)
                   ELSE TRIM(ISNULL(@c_Key2Prefix, '')) + TRIM(@c_CartonNo) END    --WL03
            , CASE WHEN TRIM(ISNULL(@c_Key3Prefix, '')) = '' 
                   THEN TRIM(@c_Storerkey)
                   ELSE TRIM(ISNULL(@c_Key3Prefix, '')) + TRIM(@c_Storerkey) END   --WL03
            , '0', '')
      
      IF @@ERROR <> 0            
      BEGIN					  
         SET @n_continue = 3  
         SET @c_errmsg = ERROR_MESSAGE()   
         SET @n_err = 60030          
         SET @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@n_err,0)) +           
                       + ': Insert into TRANSMITLOG2 Failed. (isp_EPackCtnTrack15) '
                       + '( SQLSvr MESSAGE = ' + @c_errmsg + ' ) '      

         IF @b_Debug = 1
         BEGIN
            PRINT 'isp_EPackCtnTrack15 -- Failed to INSERT INTO TRANSMITLOG2 '
         END    
         GOTO QUIT_SP          
      END 

      IF @b_Debug = 1
      BEGIN
         PRINT '>> [SEND_ITF] Inserted TRANSMITLOG2 successfully'
      END
      
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

      IF @b_Debug = 1
      BEGIN
         PRINT '>> [SEND_ITF] QCmd config loaded | @c_Command=' + ISNULL(@c_Command,'NULL')
               + ' | @c_IP=' + ISNULL(@c_IP,'NULL') + ':' + ISNULL(@c_Port,'NULL')
      END
   
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
                     + ': Error Executing isp_QCmd_SubmitTaskToQCommander. (isp_EPackCtnTrack15) '
                     + '( SQLSvr MESSAGE = ' + @c_errmsg + ' ) '    
         GOTO QUIT_SP 
      END CATCH 
   
      IF @n_Err <> 0 AND ISNULL(@c_ErrMsg,'') <> ''    
      BEGIN
         SET @n_Continue=3 
         SET @n_err = 60050   
         SET @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@n_err,0)) +           
                     + ': ' + @c_errmsg + '. (isp_EPackCtnTrack15) '
         GOTO QUIT_SP     
      END                       
   END     
        
   WHILE @@TRANCOUNT > 0        
   BEGIN        
      COMMIT TRAN        
   END        
        
   QUIT_SP: 
   
   IF @b_Debug = 1
   BEGIN
      PRINT '--- isp_EPackCtnTrack15 End ---'
   END

   IF @b_Success = 1
   BEGIN
      --Check if b_SuccessOld = 2, if yes need to set b_success to 2, prevent ECOM Packing insert PackInfo
      IF @b_SuccessOld = 2
      BEGIN
         SET @b_Success = 2
      END
   END      
        
   IF @n_Continue=3  -- Error Occured - Process And Return        
   BEGIN        
      SET @b_Success = 0        
      IF @@TRANCOUNT > 0  
      BEGIN   
         ROLLBACK TRAN        
      END  
      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'isp_EPackCtnTrack15'        
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012        
   END        
        
   WHILE @@TRANCOUNT < @n_StartTCnt        
   BEGIN        
      BEGIN TRAN        
   END        
END -- procedure 
GO
GRANT EXECUTE ON [dbo].[isp_EPackCtnTrack15] TO nSQL 
GO