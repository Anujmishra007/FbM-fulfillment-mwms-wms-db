SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
  
/*********************************************************************************/
/* Store procedure: isp_TPACK_API_PackConfirm                                    */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Update PackHeader                                            */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-09-10   1.0  GCH225     Created                                          */
/* 2025-11-12   2.0  GCH225     UWP-42536 for VAS feature                        */
/* 2026-01-14   3.0  GCH225     UWP-47048 handle SkipCartonize Logic             */
/* 2026-01-19   4.0  GCH225     UWP-47119 handle AutoPack & Carton Hold Logic    */
/*********************************************************************************/

CREATE OR ALTER  PROC [API].[isp_TPACK_API_PackConfirm] (
     @b_Debug           INT            = 0  
   , @c_Format          VARCHAR(10)    = ''  
   , @c_UserID          NVARCHAR(256)  = ''  
   , @c_OperationType   NVARCHAR(60)   = ''  
   , @c_RequestString   NVARCHAR(MAX)  = ''  
   , @b_Success         INT            = 0   OUTPUT  
   , @n_ErrNo           INT            = 0   OUTPUT  
   , @c_ErrMsg          NVARCHAR(250)  = ''  OUTPUT  
   , @c_ResponseString  NVARCHAR(MAX)  = ''  OUTPUT  
)
AS
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_DEFAULTS OFF   
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  

   DECLARE @n_Continue              INT            = 1  
         , @n_StartCnt              INT            = @@TRANCOUNT  
         , @b_sp_Success            INT  
         , @n_sp_err                INT  
         , @c_sp_errmsg             NVARCHAR(250)  = ''
         , @DBUserName              NVARCHAR(100)
         , @b_sp_ExecuteAs          BIT

   DECLARE @cType                   NVARCHAR(30)
         , @bIsDiscrete             BIT
         , @bIsCustom               BIT
         , @cLangCode               NVARCHAR(3)
         , @cPickSlipNo             NVARCHAR(10)
         , @cOrderKey               NVARCHAR(10)
         , @cLoadKey                NVARCHAR(10)
         , @cDropID                 NVARCHAR(20)
         , @cStorerKey              NVARCHAR(15)
         , @cFacility               NVARCHAR(5)
         , @nCartonNo               INT
         , @nCntOrder               INT
         , @nCntCarton              INT
         , @nCntPICKLine            INT
         , @nCntPACKLine            INT
         , @c_authority             NVARCHAR(10)
         , @cSQL                    NVARCHAR(MAX)
         , @cSQLParam               NVARCHAR(MAX)
         , @cExtPostUpdSP           NVARCHAR(30)
         , @nTtlPickQty             INT
         , @nTtlPackQty             INT
         , @bIsAutoTriggered        BIT
         , @bConfirmCloseAllFlag    BIT
         , @bRequiresConfirmation   BIT
         , @cTitle                  NVARCHAR(100)      
         , @cMessage                NVARCHAR(250)  
         , @cOPTION1                NVARCHAR(50)


   DECLARE @cIPAddress     NVARCHAR( 40)  
         , @cPortNo        NVARCHAR( 5)   
         , @cIniFilePath   NVARCHAR( 200)
         , @cCommand       NVARCHAR( MAX)
         , @nQueueID       BIGINT
         , @cQueueID       NVARCHAR(20)
         , @cDBName        NVARCHAR(30)

   SET @b_Success             = 0  
   SET @n_ErrNo               = 0  
   SET @c_ErrMsg              = ''  
   SET @c_ResponseString      = '' 
   SET @bIsDiscrete           = 1
   SET @bIsCustom             = 0
   SET @cLangCode             = ''
   SET @cPickSlipNo           = ''
   SET @cOrderKey             = ''
   SET @cLoadKey              = ''
   SET @cDropID               = ''
   SET @cStorerKey            = ''
   SET @cFacility             = ''
   SET @nCartonNo             = ''
   SET @cIPAddress            = ''
   SET @cPortNo               = ''
   SET @cIniFilePath          = ''
   SET @nQueueID              = 0
   SET @cQueueID              = ''
   SET @cDBName               = DB_NAME()
   SET @cExtPostUpdSP         = ''
   SET @nTtlPickQty           = 0
   SET @nTtlPackQty           = 0
   SET @bIsAutoTriggered      = 0
   SET @bConfirmCloseAllFlag  = 0
   SET @bRequiresConfirmation = 0
   SET @cTitle                = ''
   SET @cMessage              = ''
   SET @cOPTION1              = ''


   EXEC [API].[isp_ECOMP_ValidateAndSetUser]
        @c_UserID      = @c_UserID
      , @c_DBUserName  = @DBUserName OUTPUT
      , @b_ExecuteAs   = @b_sp_ExecuteAs OUTPUT
      , @b_Success     = @b_sp_Success OUTPUT
      , @n_ErrNo       = @n_sp_err OUTPUT
      , @c_ErrMsg      = @c_sp_errmsg OUTPUT

   IF @b_sp_Success = 0
   BEGIN    
      SET @n_Continue = 3
      SET @n_ErrNo = @n_sp_err      
      SET @c_ErrMsg = @c_sp_errmsg     
      GOTO EXIT_SP
   END

   IF @b_sp_ExecuteAs = 1 OR @DBUserName LIKE '%' + @c_UserID + '%'
   BEGIN
      EXECUTE AS LOGIN = @DBUserName
      SET @c_UserID = @DBUserName

      IF OBJECT_ID('dbo.fnc_GetUserName', 'FN') IS NOT NULL
      BEGIN
         IF dbo.fnc_GetUserName() NOT IN ('WMConnect', '')
         BEGIN
            SET @c_UserID = dbo.fnc_GetUserName()
         END
      END
   END

   --Decode Json Format
   SELECT  @cType                = cType
         , @bIsDiscrete          = bIsDiscrete
         , @bIsCustom            = bIsCustom
         , @cPickSlipNo          = cPickSlipNo
         , @cOrderKey            = cOrderKey
         , @cLoadKey             = cLoadKey
         , @cDropID              = cDropID
         , @cLangCode            = cLangCode
         , @cStorerKey           = cStorerKey
         , @cFacility            = cFacility
         , @nCartonNo            = nCartonNo
         , @bIsAutoTriggered     = bIsAutoTriggered
         , @bConfirmCloseAllFlag = bConfirmCloseAllFlag
   FROM OPENJSON(@c_RequestString)
   WITH (
	      cType                NVARCHAR(30)
	    , bIsDiscrete          BIT
	    , bIsCustom            BIT
       , cPickSlipNo          NVARCHAR(10)      
       , cOrderKey            NVARCHAR(10)
       , cLoadKey             NVARCHAR(10)      
       , cDropID              NVARCHAR(20)
       , cLangCode            NVARCHAR(3)
       , cStorerKey           NVARCHAR(15)
       , cFacility            NVARCHAR(5)
       , nCartonNo            INT
       , bIsAutoTriggered     BIT
       , bConfirmCloseAllFlag BIT
   )

   IF @cPickSlipNo = ''
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = 11901
      SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'PickSlipNo cannot be empty.'
      GOTO EXIT_SP
   END

   IF EXISTS ( SELECT 1 
               FROM PACKHEADER (NOLOCK)
               WHERE PickSlipNo = @cPickSlipNo  
               AND [Status] = '9'  
   )
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = 11909
      SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--Failed to PackConfirm, Current Pickslip already status 9.
      GOTO EXIT_SP
   END

   IF @bIsDiscrete = 0 OR (@cType <> 'pickslip' AND @cLoadKey <> '')
   BEGIN
      SELECT @nCntOrder = COUNT(DISTINCT PD.Orderkey)
           , @nCntPICKLine = COUNT(PickDetailKey)
           , @nTtlPickQty = SUM(Qty)
      FROM PICKDETAIL PD WITH (NOLOCK)
      WHERE PD.StorerKey = @cStorerKey
      AND EXISTS (SELECT 1 
                  FROM LOADPLANDETAIL LPD (NOLOCK)
                  WHERE LPD.LoadKey = @cLoadKey
                  AND LPD.OrderKey = PD.OrderKey
      )
      AND PD.[Status] <= '5'
   END
   ELSE
   BEGIN
      SELECT @nCntOrder = 1
           , @nCntPICKLine = COUNT(PickDetailKey)
           , @nTtlPickQty = SUM(Qty)
      FROM PICKDETAIL PD WITH (NOLOCK)
      WHERE PD.StorerKey = @cStorerKey
      AND PD.OrderKey = @cOrderKey
      AND PD.[Status] <= '5'
   END

   SELECT @nTtlPackQty = SUM(Qty)
        , @nCntCarton = COUNT(CartonNo)
   FROM PACKINFO (NOLOCK)
   WHERE PickSlipNo = @cPickSlipNo

   SELECT @nCntPACKLine = COUNT(1)
   FROM PACKDETAIL (NOLOCK)
   WHERE PickSlipNo = @cPickSlipNo
   
   IF @nTtlPickQty <> @nTtlPackQty
   BEGIN
      -- skip update pack confirm if cType is not pickslip and total pick vs pack is not match. else show error.
      IF @cType <> 'pickslip' AND @bIsAutoTriggered = 1
      BEGIN
         GOTO SKIP_POST_EXT_UPD
      END
      SET @n_Continue = 3
      SET @n_ErrNo = 11908
      SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--Failed to PackConfirm, Total Pick Qty not tally with Total Pack Qty.
      GOTO EXIT_SP
   END
   ELSE
   BEGIN  
      -- if some carton status not equal to 'closed' then prompt error. not allow to update packheader to 9
      IF EXISTS ( SELECT 1 
                  FROM PACKINFO (NOLOCK)
                  WHERE PickSlipNo = @cPickSlipNo
                  AND CartonStatus <> 'CLOSED'
      )       
      BEGIN
         IF @bIsAutoTriggered = 1
         BEGIN
            SET @n_Continue = 3 

            SELECT @cOPTION1 = ISNULL(RTRIM(OPTION1),'')
            FROM STORERCONFIG (NOLOCK)
            WHERE StorerKey = @cStorerKey
            AND ConfigKey = 'TPS-AutoPack'
            AND sValue = '1'

            -- Option1 set to 1 means skip the alert error prompt that indicate some carton still under hold status else show error alert
            IF @cOPTION1 <> '1'
            BEGIN
               SET @n_ErrNo = 11914    
               SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Auto Pack Confirmation failed. Please ensure all cartons are marked as "Closed".'  
            END

            GOTO EXIT_SP  
         END
         ELSE
         BEGIN
            IF @bConfirmCloseAllFlag = 0
            BEGIN
               SET @bRequiresConfirmation = 1
               SET @cTitle = API.TouchPadGetMessage( 11910, @cLangCode, 'DSP')
               SET @cMessage = API.TouchPadGetMessage( 11911, @cLangCode, 'DSP')
               GOTO SKIP_POST_EXT_UPD
            END
            ELSE
            BEGIN
               IF EXISTS ( SELECT 1 
                           FROM STORERCONFIG (NOLOCK)
                           WHERE StorerKey = @cStorerKey
                           AND ConfigKey = 'TPS-skipCartonize'
                           AND sValue = '0'
               )
               BEGIN
                  SET @n_Continue = 3  
                  SET @n_ErrNo = 11913    
                  SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Close All Carton. Please manually close all the hold carton with carton type selection.'  
                  GOTO EXIT_SP  
               END

               UPDATE PACKINFO WITH (ROWLOCK)
               SET CartonStatus = 'CLOSED'
               WHERE PickSlipNo = @cPickSlipNo

               IF @@ERROR <> 0  
               BEGIN  
                  SET @n_Continue = 3  
                  SET @n_ErrNo = 11912    
                  SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Update the PackInfo CartonStatus.'  
                  GOTO EXIT_SP  
               END 
            END
         END
      END
   END

   IF (@nCntOrder > 50 OR @nCntPICKLine > 500) AND (@nCntCarton > 50 OR @nCntPACKLine > 500)
   BEGIN
      SELECT  @cPortNo = SHORT
            , @cIPAddress = Long
            , @cIniFilePath = UDF01
      FROM CODELKUP (NOLOCK) 
      WHERE LISTNAME = 'TPQMDSVC'
      AND Storerkey='ALL'

      IF @@ROWCOUNT = 0
      BEGIN
         SET @n_Continue = 3
         SET @n_ErrNo = 11903    
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') --No TPQMDSVC Config been configured in Codelkup.
         GOTO EXIT_SP     
      END
         
      SET @cCommand = ' UPDATE PACKHEADER WITH (ROWLOCK) SET [Status] = ''9'' WHERE PickSlipNo = ''' + @cPickSlipNo + ''''

      INSERT INTO TCPSocket_QueueTask( CmdType
                                     , Cmd
                                     , StorerKey
                                     , [Port]
                                     , TargetDB
                                     , [IP]
                                     , TransmitLogKey
                                     , DataStream
                                     )               
                               VALUES( 'SQL'
                                     , @cCommand
                                     , @cStorerKey
                                     , @cPortNo
                                     , @cDBName
                                     , @cIPAddress
                                     , ''
                                     , 'TPS'
                                     )   

      SELECT @nQueueID = SCOPE_IDENTITY()
            , @n_ErrNo = @@ERROR    
         
      SET @cQueueID = TRY_CAST(@nQueueID AS NVARCHAR(20))

      IF @n_ErrNo <> 0    
      BEGIN    
         SET @n_Continue = 3
         SET @n_ErrNo = 11904    
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') --Failed to insert command into TCPSocket_QueueTask.
         GOTO EXIT_SP     
      END  

      SET @cCommand  = '<STX>'     
                     + 'SQL|' 
                     + @cQueueID + '|'    
                     + @cDBName + '|'      
                     + 'EXEC isp_QCmd_ExecuteSQL '    
                     + ' @cTargetDB=''' + @cDBName + '''' 
                     + ', @nQTaskID=' + @cQueueID  
                     + ', @cPort=''' + @cPortNo + '''' 
                     + '<ETX>'  

         -- Call Qcommander    
      EXEC isp_QCmd_SendTCPSocketMsg    
           @cApplication  = 'QCommander'    
         , @cStorerKey    = @cStorerKey     
         , @cMessageNum   = @cQueueID    
         , @cData         = @cCommand    
         , @cIP           = @cIPAddress    
         , @cPORT         = @cPortNo     
         , @cIniFilePath  = @cIniFilePath     
         , @cDataReceived = '' --@cDataReceived OUTPUT,    
         , @bSuccess      = @b_Success      OUTPUT    
         , @nErr          = @n_ErrNo        OUTPUT     
         , @cErrMsg       = @c_ErrMsg       OUTPUT    

      IF @n_ErrNo <> 0    
      BEGIN
         EXEC dbo.isp_QCmd_UpdateQueueTaskStatus    
            @cTargetDB    = @cDBName,    
            @nQTaskID     = @nQueueID,     
            @cQStatus     = 'X',    
            @cThreadID    = '',    
            @cMsgRecvDate = '',    
            @cQErrMsg     = ''    
            -- @bSuccess     = @bSuccess OUTPUT,     
            -- @nErr         = @@n_ErrNo   OUTPUT,     
            -- @cErrMsg      = @cErrMsg  OUTPUT    
         IF @@ERROR <> 0    
         BEGIN    
            SET @n_Continue = 3
            SET @n_ErrNo = 11905    
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') --Failed to Update the QueueTaskStatus.
            GOTO EXIT_SP  
         END    
      END 
      GOTO SKIP_NORMAL_UPDATE
   END

   UPDATE PACKHEADER WITH (ROWLOCK) 
   SET [Status] = '9'   
   WHERE PickSlipNo = @cPickSlipNo  
   AND [Status] <> '9'  
      
   IF @@ERROR <> 0  
   BEGIN  
      SET @n_Continue = 3  
      SET @n_ErrNo = 11906    
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Update the PackHeader Status.'  
      GOTO EXIT_SP  
   END 

SKIP_NORMAL_UPDATE:
      
   EXEC nspGetRight    
      @c_Facility   = @cFacility      
   ,  @c_StorerKey  = @cStorerKey     
   ,  @c_sku        = ''           
   ,  @c_ConfigKey  = 'AssignPackLabelToOrdCfg'     
   ,  @b_Success    = @b_Success       OUTPUT    
   ,  @c_authority  = @c_authority     OUTPUT     
   ,  @n_err        = @n_ErrNo         OUTPUT    
   ,  @c_errmsg     = @c_ErrMsg        OUTPUT    

   IF @c_authority <> '1'
   BEGIN
      GOTO SKIP_POST_EXT_UPD
   END

   EXEC isp_AssignPackLabelToOrderByLoad
        @c_Pickslipno   = @cPickSlipNo  
      , @b_Success      = @b_Success   OUTPUT
      , @n_Err          = @n_ErrNo     OUTPUT
      , @c_ErrMsg       = @c_ErrMsg    OUTPUT

   IF @b_Success = 0
   BEGIN
      SET @n_Continue = 3   
      GOTO EXIT_SP
   END

   EXEC [API].[isp_TPACK_ExtPostUpd_Wrapper]
     @cType       = @cType            
   , @bIsDiscrete = @bIsDiscrete      
   , @bIsCustom   = @bIsCustom        
   , @cPickSlipNo = @cPickSlipNo       
   , @cOrderKey   = @cOrderKey         
   , @cLoadKey    = @cLoadKey          
   , @cDropID     = @cDropID           
   , @cStorerKey  = @cStorerKey        
   , @cFacility   = @cFacility         
   , @nCartonNo   = @nCartonNo
   , @c_UserID    = @c_UserID
   , @cLangCode   = @cLangCode
   , @b_Success   = @b_Success   OUTPUT
   , @n_ErrNo     = @n_ErrNo     OUTPUT
   , @c_ErrMsg    = @c_ErrMsg    OUTPUT

   IF @b_Success = 0
   BEGIN
      SET @n_Continue = 3  
      GOTO EXIT_SP
   END

SKIP_POST_EXT_UPD:
   SET @b_Success = 1  
   SET @c_ResponseString = ISNULL ((SELECT CAST(@b_Success AS BIT)   AS bSuccess 
                                         , @bRequiresConfirmation    AS bRequiresConfirmation
                                         , @cTitle                   AS cTitle
                                         , @cMessage                 AS cMessage
                                         , @nQueueID                 AS nQueueID
                                    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                           ),'')

EXIT_SP:
   IF @n_Continue = 3  -- Error Occured - Process And Return      
   BEGIN      
      SET @b_Success = 0      
      IF @@TRANCOUNT > @n_StartCnt AND @@TRANCOUNT = 1 
      BEGIN               
         ROLLBACK TRAN      
      END      
      ELSE      
      BEGIN      
         WHILE @@TRANCOUNT > @n_StartCnt      
         BEGIN      
            COMMIT TRAN      
         END      
      END   
      RETURN      
   END      
   ELSE      
   BEGIN      
      SELECT @b_Success = 1      
      WHILE @@TRANCOUNT > @n_StartCnt      
      BEGIN      
         COMMIT TRAN      
      END      
      RETURN      
   END
END