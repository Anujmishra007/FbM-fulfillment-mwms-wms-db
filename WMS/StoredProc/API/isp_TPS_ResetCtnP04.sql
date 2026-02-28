
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/******************************************************************************/
/* Store procedure: isp_TPS_ResetCtnP04                                       */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Date         Rev  Author     Purposes                                      */
/* 2025-09-22   1.0  GCH225     FCR-7968 Created                              */
/******************************************************************************/

CREATE  OR ALTER PROC [API].[isp_TPS_ResetCtnP04] (
	@json       NVARCHAR( MAX),
   @jResult    NVARCHAR( MAX) OUTPUT,
   @b_Success  INT = 1        OUTPUT,
   @n_Err      INT = 0        OUTPUT,
   @c_ErrMsg   NVARCHAR( 255) = ''  OUTPUT
)
AS

SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF
BEGIN
	
   DECLARE  @cLangCode        NVARCHAR( 3)  
          , @cSerialno        NVARCHAR(30)  
          , @cSerialNoKey     NVARCHAR(10)
          , @cStorerKey       NVARCHAR( 15)  
          , @cFacility        NVARCHAR( 5)  
          , @nFunc            INT 
          , @cUserName        NVARCHAR( 128) 
          , @c_UserName       NVARCHAR( 128) 
          , @cScanNo          NVARCHAR( 50)  
          , @cDropID          NVARCHAR( 50)  
          , @cPickSlipNo      NVARCHAR( 30)  
          , @nCartonNo        INT  
          , @cType            NVARCHAR( 30)  
          , @cResetCartonJson NVARCHAR( MAX)  
          , @cResetAll        NVARCHAR( 1)  
          , @cLoadKey         NVARCHAR( 10)  
          , @cOrderKey        NVARCHAR( 10)  
          , @nTranCount       INT  
          , @cScanNoType      NVARCHAR( 30)  
          , @cZone            NVARCHAR( 18)
          , @cUCCNo           NVARCHAR( 20)
          , @cSQL             NVARCHAR(4000)
          , @cSQLParam        NVARCHAR(4000)

          , @bADAllowInsertExistingSerialNoFlag BIT
          , @cSKU             NVARCHAR(20)
          , @bADFlag          BIT
          , @bSNCaptureFlag   BIT
          , @cUserDefine02    NVARCHAR(30)

   DECLARE @nOutputCount INT
   DECLARE @b_ExecuteAs BIT 

   SET @bADAllowInsertExistingSerialNoFlag = 0
   SET @cSKU            = ''
   SET @bADFlag         = 0
   SET @bSNCaptureFlag  = 0
   SET @cUserDefine02   = ''
   SET @b_ExecuteAs     = 0

   SET @nTranCount = @@TRANCOUNT  
   BEGIN TRAN  
   SAVE TRAN isp_TPS_ResetCtnP04 

   SELECT @cStorerKey = StorerKey
        , @cFacility = Facility
        , @nFunc = Func
        , @cUserName = UserName
        , @cLangCode = LangCode
        , @cScanNo = ScanNo
        , @nCartonNo = CartonNo
        , @ctype = cType
        , @cResetCartonJson=ResetCarton
        , @cResetAll = ResetAll  
   FROM OPENJSON(@json)  
   WITH (  
      StorerKey   NVARCHAR(30)  
    , Facility    NVARCHAR(30)  
    , Func        NVARCHAR(5)  
    , UserName    NVARCHAR(15)  
    , LangCode    NVARCHAR(3)  
    , ScanNo      NVARCHAR(30)  
    , CartonNo    INT  
    , CartonID    NVARCHAR(20)  
    , cType       NVARCHAR(30)  
    , ResetCarton NVARCHAR(MAX) as JSON  
    , ResetAll    NVARCHAR(1)  
   )  
  
   SELECT @cStorerKey AS StorerKey, @cFacility AS Facility,@nFunc AS Func,@cUserName AS UserName,@cScanNo AS ScanNo,@nCartonNo AS CartonNo, @cResetAll as ResetAll   

   SET @c_UserName = @cUserName

   SET @n_Err = 0

   SET @cSQL = 'EXEC WM.lsp_SetUser @c_UserName OUTPUT, @n_Err OUTPUT, @c_ErrMsg OUTPUT';

   SET @cSQLParam =  N'@c_UserName NVARCHAR(128) OUTPUT,' +
			       N'@n_Err INT OUTPUT, ' + 
			       N'@c_ErrMsg NVARCHAR(125) OUTPUT'
   --convert login
   SELECT @nOutputCount=COUNT(1) FROM sys.parameters p (NOLOCK)
	      JOIN sys.objects o (NOLOCK) 
	         ON p.object_id = o.object_id
	      WHERE o.name = 'lsp_SetUser'
	      AND p.is_output = 1
   IF @nOutputCount = 4 
   BEGIN
     SET @cSQL = @cSQL + ', @b_ExecuteAs OUTPUT '
     SET @cSQLParam = @cSQLParam + ', @b_ExecuteAs BIT OUTPUT'

     EXEC sp_executesql @cSQL, @cSQLParam, @c_UserName OUTPUT, @n_Err OUTPUT, @c_ErrMsg OUTPUT, @b_ExecuteAs OUTPUT;
   END
   ELSE
   BEGIN
     EXEC sp_executesql @cSQL, @cSQLParam, @c_UserName OUTPUT, @n_Err OUTPUT, @c_ErrMsg OUTPUT
   END

   IF @n_Err <> 0  
   BEGIN  
      --INSERT INTO @errMsg(nErrNo,cErrMsg)  
      SET @b_Success = 0  
      SET @n_Err = @n_Err  
   --   SET @c_ErrMsg = @c_ErrMsg  
      GOTO ROLLBACKTRAN  
   END  

   IF @nOutputCount = 4
   BEGIN
     IF @b_ExecuteAs = 1
	    GOTO ExecuteAs
     ELSE
     BEGIN
	    IF SESSION_CONTEXT(N'mwms_user_name') IS NULL
	    BEGIN
	      SET @b_Success = 0
	      SET @n_Err = 1003351
	      SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'No Session context found. Function : isp_TPS_ResetCtnP04'
	      GOTO ROLLBACKTRAN
	    END            
     END
   END
   ELSE
   BEGIN
     IF @c_UserName LIKE '%' + @cUserName + '%'
     BEGIN
ExecuteAs:
	    EXECUTE AS LOGIN = @c_UserName
	    SET @cUserName = @c_UserName
     END
   END      

   --check pickslipNo  
   EXEC [API].[isp_GetPicklsipNo] @cStorerKey,@cFacility,@nFunc,@cLangCode,@cScanNo,@cType,@cUserName, @jResult OUTPUT,@b_Success OUTPUT,@n_Err OUTPUT,@c_ErrMsg OUTPUT  

   IF @n_Err <>0  
   BEGIN  
    SET @jResult = ''  
    SET @b_Success = 0  
      SET @n_Err = @n_Err  
      SET @c_ErrMsg = @c_ErrMsg  

      GOTO ROLLBACKTRAN  
   END  

   --Decode pickslipNo Json Format  
   SELECT @cScanNoType = ScanNoType, @cpickslipNo = PickslipNo, @cDropID = DropID,  @cOrderKey=ISNULL(OrderKey,''), @cLoadKey = LoadKey, @cZone = Zone--, @EcomSingle = EcomSingle  
   --, @cDynamicRightName1 = DynamicRightName1, @cDynamicRightValue1 = DynamicRightValue1  
   --,@pickSkuDetailJson = PickSkuDetail  
   FROM OPENJSON(@jResult)  
   WITH (  
      ScanNoType        NVARCHAR( 30)  
    , PickslipNo        NVARCHAR( 30)  
    , DropID            NVARCHAR( 30)  
    , OrderKey          NVARCHAR( 10)  
    , LoadKey           NVARCHAR( 10)  
    , Zone              NVARCHAR( 18)  
    , EcomSingle        NVARCHAR( 1)  
    , DynamicRightName1    NVARCHAR( 30)  
    , DynamicRightValue1   NVARCHAR( 30)  
    , PickSkuDetail     NVARCHAR( MAX) as json  
   )  
   SELECT @cScanNoType as ScanNoType, @cpickslipNo as PickslipNo, @cDropID as DropID,  @cOrderKey as OrderKey, @cLoadKey as LoadKey, @cZone as Zone--, @EcomSingle as EcomSingle  

   SELECT @cPickSlipNo AS pickslipno  

   IF EXISTS ( SELECT 1 
					FROM STORERCONFIG (NOLOCK)
					WHERE StorerKey = @cStorerKey
						AND ConfigKey='ADAllowInsertExistingSerialNo'
						AND Option1 =''
   )
	BEGIN
		SET @bADAllowInsertExistingSerialNoFlag = 1
	END

   --reset 1 carton  
   IF @cResetAll <> '1'  
   BEGIN   
      IF EXISTS ( SELECT 1  
                  FROM SERIALNO (NOLOCK)  
                  WHERE PickSlipNo=@cpickslipno    
                  AND CartonNo = @nCartonNo    
                  AND StorerKey=@cStorerKey 
                  AND [Status] <'6')
      BEGIN
         DECLARE CurSN CURSOR LOCAL READ_ONLY FAST_FORWARD FOR  
         SELECT  SN.SerialNoKey
               , SN.SerialNo
               , SN.SKU
               --, IIF(S.Susr4 = 'AD', 1, 0)
               --, IIF(S.SerialNoCapture IN('1','3'), 1, 0)
               --, ISNULL(RTRIM(SN.UserDefine02),'')
         FROM SERIALNO SN (NOLOCK)  
         --INNER JOIN SKU S (NOLOCK)
         --ON SN.StorerKey = S.StorerKey
         --AND SN.SKU = S.SKU
         WHERE SN.PickSlipNo=@cpickslipno    
         AND SN.CartonNo = @nCartonNo    
         AND SN.StorerKey=@cStorerKey 
         AND SN.[Status] <'6'

         OPEN CurSN;  
         FETCH NEXT FROM CurSN INTO @cSerialNoKey, @cSerialno, @cSKU --, @bADFlag, @bSNCaptureFlag, @cUserDefine02
         WHILE @@FETCH_STATUS = 0  
         BEGIN 
            IF @bADAllowInsertExistingSerialNoFlag = 1 
            --AND (@bADFlag = 1 OR @bSNCaptureFlag = 1) AND
            --@cUserDefine02 <> '' AND 
            --EXISTS(SELECT 1 
            --       FROM UPC (NOLOCK)
            --       WHERE StorerKey = @cStorerKey
            --       AND SKU = @cSKU
            --       AND UPC = @cUserDefine02
            --)
            BEGIN
               DELETE FROM SERIALNO
               WHERE SerialNoKey = @cSerialNoKey

               IF @@ERROR <> 0  
               BEGIN  
                  SET @b_Success = 0  
                  SET @n_Err = 1003352  
                  SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Unable to Delete SerialNo. Function : isp_TPS_ResetCtnP04
                  GOTO RollBackTran  
               END 
            END
            ELSE
            BEGIN
               UPDATE SerialNo WITH (ROWLOCK)  
               SET   [Status]='1',  
                     ORDERKEY='',
                     OrderLineNumber='',
                     LabelLine = '',
                     CartonNo = '',
                     PickSlipNo = '',  
                     EditDate = GETDATE(),  
                     EditWho = @cUserName
               WHERE SerialNoKey = @cSerialNoKey
            
               IF @@ERROR <> 0  
               BEGIN  
                  SET @b_Success = 0  
                  SET @n_Err = 1003353  
                  SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Unable to Update SerialNo. Function : isp_TPS_ResetCtnP04
                  GOTO RollBackTran  
               END  
            END
            FETCH NEXT FROM CurSN INTO @cSerialNoKey, @cSerialno, @cSKU --, @bADFlag, @bSNCaptureFlag, @cUserDefine02
         END 
         CLOSE CurSN  
         DEALLOCATE CurSN  
      END
      ELSE
      BEGIN
         IF ISNULL(@cOrderkey,'') = ''
         BEGIN
            SELECT @cOrderkey = OrderKey
            FROM PICKHEADER (NOLOCK)
            WHERE PickHeaderKey = @cPickslipno
         END

         IF EXISTS ( SELECT 1
                     FROM SERIALNO (NOLOCK)
                     WHERE OrderKey = @cOrderkey
                     AND OrderLineNumber = ''
                     AND PickSlipNo = ''
                     AND CartonNo = ''
                     AND [Status] IN( '1',  '6') 
                     AND StorerKey = @cstorerkey  
         )
         BEGIN
            DECLARE CurSN2 CURSOR LOCAL READ_ONLY FAST_FORWARD FOR  
            SELECT  SN.SerialNoKey
                  , SN.SerialNo
                  , SN.SKU
                  --, IIF(S.Susr4 = 'AD', 1, 0)
                  --, IIF(S.SerialNoCapture IN('1','3'), 1, 0)
                  --, ISNULL(RTRIM(SN.UserDefine02),'')
            FROM SERIALNO SN (NOLOCK)  
            --INNER JOIN SKU S (NOLOCK)
            --ON SN.StorerKey = S.StorerKey
            --AND SN.SKU = S.SKU
            WHERE SN.OrderKey = @cOrderkey
            AND SN.OrderLineNumber = ''
            AND SN.PickSlipNo = ''
            AND SN.CartonNo = ''
            AND SN.[Status] IN( '1',  '6') 
            AND SN.StorerKey = @cstorerkey   

            OPEN CurSN2;  
            FETCH NEXT FROM CurSN2 INTO @cSerialNoKey, @cSerialno, @cSKU --, @bADFlag, @bSNCaptureFlag, @cUserDefine02
            WHILE @@FETCH_STATUS = 0  
            BEGIN
               IF @bADAllowInsertExistingSerialNoFlag = 1  
               --AND (@bADFlag = 1 OR @bSNCaptureFlag = 1) 
               --AND @cUserDefine02 <> ''  
               --AND EXISTS(SELECT 1 
               --       FROM UPC (NOLOCK)
               --       WHERE StorerKey = @cStorerKey
               --       AND SKU = @cSKU
               --       AND UPC = @cUserDefine02
               --)
               BEGIN
                  DELETE FROM SERIALNO
                  WHERE SerialNoKey = @cSerialNoKey

                  IF @@ERROR <> 0  
                  BEGIN  
                     SET @b_Success = 0  
                     SET @n_Err = 1003354  
                     SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Unable to Delete SerialNo. Function : isp_TPS_ResetCtnP04
                     GOTO RollBackTran  
                  END 
               END
               ELSE
               BEGIN
                  UPDATE SerialNo WITH (ROWLOCK)  
                  SET   STATUS='1',  
                        ORDERKEY='',
                        OrderLineNumber='',
                        LabelLine = '',
                        CartonNo = '',
                        pickslipno = '',  
                        EditDate = GETDATE(),  
                        EditWho = @cUserName
                  WHERE SerialNoKey = @cSerialNoKey
              
                  IF @@ERROR <> 0  
                  BEGIN  
                     SET @b_Success = 0  
                     SET @n_Err = 1003355  
                     SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Unable to Update SerialNo. Function : isp_TPS_ResetCtnP04
                     GOTO RollBackTran  
                  END 
               END
               FETCH NEXT FROM CurSN2 INTO @cSerialNoKey, @cSerialno, @cSKU --, @bADFlag, @bSNCaptureFlag, @cUserDefine02
            END
            CLOSE CurSN2  
            DEALLOCATE CurSN2  
         END
      END

      SELECT @cUCCNo = UCCNo
      FROM PACKINFO (NOLOCK)
      WHERE PickSlipNo = @cPickSlipNo 
      AND CartonNo = @nCartonNo 

      DELETE FROM PACKSERIALNO
      WHERE PickSlipNo = @cPickSlipNo 
      AND CartonNo = @nCartonNo 

      IF @@ERROR <> 0  
      BEGIN  
         SET @b_Success = 0  
         SET @n_Err = 1003356  
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Unable to Delete PackSerialNo. Function : isp_TPS_ResetCtnP04  
         GOTO RollBackTran  
      END

      DELETE FROM PACKINFO
      WHERE PickSlipNo = @cPickSlipNo 
      AND CartonNo = @nCartonNo 

      IF @@ERROR <> 0  
      BEGIN  
         SET @b_Success = 0  
         SET @n_Err = 1003357  
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Unable to Delete PackInfo. Function : isp_TPS_ResetCtnP04  
         GOTO RollBackTran  
      END

      --delete packDetail  
      DELETE FROM PACKDETAIL 
      WHERE PickSlipNo = @cPickSlipNo 
      AND CartonNo = @nCartonNo 
      AND ArchiveCop = NULL

      IF @@ERROR <> 0  
      BEGIN  
         SET @b_Success = 0  
         SET @n_Err = 1003358  
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Unable to Delete PackDetail. Function : isp_TPS_ResetCtnP04  
         GOTO RollBackTran  
      END  

      IF @cUCCNo <> ''
      BEGIN
         UPDATE UCC
         SET   [Status] ='3',
               EditDate = GETDATE(),  
               EditWho = @cUserName
         WHERE UCCNO = @cUCCNo

         IF @@ERROR <> 0  
         BEGIN  
            SET @b_Success = 0  
            SET @n_Err = 1003359  
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Unable to Update UCC. Function : isp_TPS_ResetCtnP04'  
            GOTO RollBackTran  
         END  
      END  
   END  
  
   --reset all carton  
   IF @cResetAll = '1'  
   BEGIN  
      IF EXISTS ( SELECT 1 
                  FROM PACKHEADER WITH (NOLOCK) 
                  WHERE PickSlipNo = @cPickSlipNo
                  AND STATUS = '9'
      )  
      BEGIN  
         SET @b_Success = 0  
         SET @n_Err = 1003360  
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Packed Pickslip not able to reset. Function : isp_TPS_ResetCtnP04'  
         GOTO RollBackTran  
      END  
      IF EXISTS ( SELECT 1  
                  FROM SERIALNO (NOLOCK)  
                  WHERE PickSlipNo=@cpickslipno    
                  AND StorerKey=@cStorerKey 
                  AND [Status] <'6')
      BEGIN
      
         DECLARE CurSN CURSOR LOCAL READ_ONLY FAST_FORWARD FOR  
         SELECT  SN.SerialNoKey
               , SN.SerialNo
               , SN.SKU
               --, IIF(S.Susr4 = 'AD', 1, 0)
               --, IIF(S.SerialNoCapture IN('1','3'), 1, 0)
               --, ISNULL(RTRIM(SN.UserDefine02),'')
         FROM SERIALNO SN (NOLOCK)  
         --INNER JOIN SKU S (NOLOCK)
         --ON SN.StorerKey = S.StorerKey
         --AND SN.SKU = S.SKU
         WHERE SN.PickSlipNo=@cpickslipno
         AND SN.StorerKey=@cStorerKey 
         AND SN.[Status] <'6'

         OPEN CurSN;  
         FETCH NEXT FROM CurSN INTO @cSerialNoKey, @cSerialno, @cSKU --, @bADFlag, @bSNCaptureFlag, @cUserDefine02
         WHILE @@FETCH_STATUS = 0  
         BEGIN
            IF @bADAllowInsertExistingSerialNoFlag = 1  
            --AND (@bADFlag = 1 OR @bSNCaptureFlag = 1) 
            --AND @cUserDefine02 <> ''
            --AND EXISTS(SELECT 1 
            --         FROM UPC (NOLOCK)
            --         WHERE StorerKey = @cStorerKey
            --         AND SKU = @cSKU
            --         AND UPC = @cUserDefine02
            --)
            BEGIN
               DELETE FROM SERIALNO
               WHERE SerialNoKey = @cSerialNoKey

               IF @@ERROR <> 0  
               BEGIN  
                  SET @b_Success = 0  
                  SET @n_Err = 1003361  
                  SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Unable to Delete SerialNo. Function : isp_TPS_ResetCtnP04
                  GOTO RollBackTran  
               END 
            END
            ELSE
            BEGIN
               UPDATE SerialNo WITH (ROWLOCK)  
               SET   STATUS='1',  
                     ORDERKEY='',
                     OrderLineNumber='',
                     LabelLine = '',
                     CartonNo = '',
                     pickslipno = '',  
                     EditDate = GETDATE(),  
                     EditWho = @cUserName
               WHERE SerialNoKey = @cSerialNoKey

               IF @@ERROR <> 0  
               BEGIN  
                  SET @b_Success = 0  
                  SET @n_Err = 1003362  
                  SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Unable to Update SerialNo. Function : isp_TPS_ResetCtnP04
                  GOTO RollBackTran  
               END  
            END
            FETCH NEXT FROM CurSN INTO @cSerialNoKey, @cSerialno, @cSKU --, @bADFlag, @bSNCaptureFlag, @cUserDefine02
         END  
         CLOSE CurSN  
         DEALLOCATE CurSN  
      END
      ELSE
      BEGIN
         IF ISNULL(@cOrderkey,'') = ''
         BEGIN
            SELECT @cOrderkey = OrderKey
            FROM PICKHEADER (NOLOCK)
            WHERE PickHeaderKey = @cPickslipno
         END

         IF EXISTS ( SELECT 1
                     FROM SERIALNO (NOLOCK)
                     WHERE Orderkey = @cOrderkey
                     AND [Status] IN( '1',  '6') 
                     AND StorerKey = @cstorerkey  )
         BEGIN
            DECLARE CurSN2 CURSOR LOCAL READ_ONLY FAST_FORWARD FOR  
            SELECT  SN.SerialNoKey
                  , SN.SerialNo
                  , SN.SKU
                  --, IIF(S.Susr4 = 'AD', 1, 0)
                  --, IIF(S.SerialNoCapture IN('1','3'), 1, 0)
                  --, ISNULL(RTRIM(SN.UserDefine02),'')
            FROM SERIALNO SN (NOLOCK)  
            --INNER JOIN SKU S (NOLOCK)
            --ON SN.StorerKey = S.StorerKey
            --AND SN.SKU = S.SKU
            WHERE SN.Orderkey = @cOrderkey
            AND SN.[Status] IN( '1',  '6') 
            AND SN.StorerKey = @cstorerkey   

            OPEN CurSN2;  
            FETCH NEXT FROM CurSN2 INTO @cSerialNoKey, @cSerialno, @cSKU --, @bADFlag, @bSNCaptureFlag, @cUserDefine02
            WHILE @@FETCH_STATUS = 0  
            BEGIN
               IF @bADAllowInsertExistingSerialNoFlag = 1  
               --AND (@bADFlag = 1 OR @bSNCaptureFlag = 1) 
               --AND @cUserDefine02 <> ''  
               --AND EXISTS(SELECT 1 
               --         FROM UPC (NOLOCK)
               --         WHERE StorerKey = @cStorerKey
               --         AND SKU = @cSKU
               --         AND UPC = @cUserDefine02
               --)
               BEGIN
                  DELETE FROM SERIALNO
                  WHERE SerialNoKey = @cSerialNoKey

                  IF @@ERROR <> 0  
                  BEGIN  
                     SET @b_Success = 0  
                     SET @n_Err = 1003363  
                     SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Unable to Delete SerialNo. Function : isp_TPS_ResetCtnP04
                     GOTO RollBackTran  
                  END 
               END
               ELSE
               BEGIN
                  UPDATE SerialNo WITH (ROWLOCK)  
                  SET   STATUS = '1',  
                        ORDERKEY = '',
                        OrderLineNumber = '',
                        LabelLine = '',
                        CartonNo = '',
                        pickslipno = '', 
                        EditDate = GETDATE(),  
                        EditWho = @cUserName
                  WHERE SerialNoKey = @cSerialNoKey
              
                  IF @@ERROR <> 0  
                  BEGIN  
                     SET @b_Success = 0  
                     SET @n_Err = 1003364  
                     SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Unable to Update SerialNo. Function : isp_TPS_ResetCtnP04
                     GOTO RollBackTran  
                  END 
               END
               FETCH NEXT FROM CurSN2 INTO @cSerialNoKey, @cSerialno, @cSKU --, @bADFlag, @bSNCaptureFlag, @cUserDefine02
            END
            CLOSE CurSN2  
            DEALLOCATE CurSN2  
         END 
      END

      UPDATE U WITH (ROWLOCK)
      SET   [Status]='3',  
            EditDate = GETDATE(),  
            EditWho = @cUserName
      FROM UCC U
      WHERE EXISTS ( SELECT 1 
                     FROM PACKINFO P (NOLOCK)
                     WHERE P.PickSlipNo = @cPickSlipNo
                     AND P.UCCNo = U.UCCNo
                     )

      IF @@ERROR <> 0  
      BEGIN  
         SET @b_Success = 0  
         SET @n_Err = 1003365  
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Unable to Update UCC. Function : isp_TPS_ResetCtnP04'  
         GOTO RollBackTran  
      END

      DELETE FROM PACKSERIALNO
      WHERE PickSlipNo = @cPickSlipNo 

      IF @@ERROR <> 0  
      BEGIN  
         SET @b_Success = 0  
         SET @n_Err = 1003366  
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Unable to Delete PackSerialNo. Function : isp_TPS_ResetCtnP04  
         GOTO RollBackTran  
      END

      DELETE FROM PACKINFO
      WHERE PickSlipNo = @cPickSlipNo 

      IF @@ERROR <> 0  
      BEGIN  
         SET @b_Success = 0  
         SET @n_Err = 1003367  
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Unable to Delete PackInfo. Function : isp_TPS_ResetCtnP04  
         GOTO RollBackTran  
      END

      --delete packDetail  
      DELETE FROM PACKDETAIL 
      WHERE PickSlipNo = @cPickSlipNo 
      AND ArchiveCop = NULL

      IF @@ERROR <> 0  
      BEGIN  
         SET @b_Success = 0  
         SET @n_Err = 1003368  
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Unable to Delete PackDetail. Function : isp_TPS_ResetCtnP04  
         GOTO RollBackTran  
      END  
   END  

   --COMMIT TRAN isp_TPS_ResetCtnP04  
   SET @b_Success = 1  
   SET @jResult = '[{Success}]'  
      GOTO Quit  

RollBackTran:  
--Revert  
ROLLBACK TRAN isp_TPS_ResetCtnP04  
  
Quit:  
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started  
      COMMIT TRAN isp_TPS_ResetCtnP04  

   IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'lsp_RevertUser' AND type = 'P') AND SESSION_CONTEXT(N'mwms_user_name') IS NOT NULL
   BEGIN
      EXEC [WM].[lsp_RevertUser]
   END
END

