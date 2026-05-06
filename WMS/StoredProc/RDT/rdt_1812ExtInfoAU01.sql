SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
  
/************************************************************************/  
/* Store procedure: rdt_1812ExtInfoAU01                                 */  
/* Copyright      : Maersk                                              */  
/*                                                                      */  
/* Purpose: Extended info                                               */  
/*                                                                      */  
/* Modifications log:                                                   */  
/* Date         Author    Ver.  Purposes                                */  
/* 2025-05-26   SYC067    1.0   FCR-XXXX Created                        */  
/************************************************************************/  
  
CREATE OR ALTER  PROCEDURE [RDT].[rdt_1812ExtInfoAU01]  
    @nMobile         INT  
   ,@nFunc           INT  
   ,@cLangCode       NVARCHAR( 3)  
   ,@nStep           INT  
   ,@cTaskdetailKey  NVARCHAR( 10)  
   ,@cExtendedInfo1  NVARCHAR( 20) OUTPUT  
   ,@nErrNo          INT           OUTPUT  
   ,@cErrMsg         NVARCHAR( 20) OUTPUT  
   ,@nAfterStep      INT = 0  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   DECLARE @cDropID NVARCHAR( 20)  
  
   -- TM Case Pick  
   IF @nFunc = 1812  
   BEGIN  
      DECLARE @cConsigneeKey NVARCHAR( 15) = ''  
      DECLARE @cBillToKey    NVARCHAR( 20) = ''  
      DECLARE @cOrderType    NVARCHAR( 20) = ''  
  
      DECLARE @cCustomerType1     NVARCHAR( 20) = '' --PALLET / CASE  
      DECLARE @cCustomerType2     NVARCHAR( 20) = '' --SANDWICH / RAINBOW  
      DECLARE @cCustomerType3     NVARCHAR( 20) = '' --MAX SKU PER PALLET  
      DECLARE @cCustomerType4     NVARCHAR( 20) = '' --PALLET TYPE: CHEP / LOSCAM / PLAIN  
      DECLARE @cPlanningType     NVARCHAR( 20) = '' --WAVE / LOAD  
      DECLARE @cPWaveKey         NVARCHAR( 20) = ''  
      DECLARE @cPLoadkey         NVARCHAR( 20) = ''  
      DECLARE @cPickPalletType   NVARCHAR( 20) = ''  
      DECLARE @cPickCaseType     NVARCHAR( 20) = ''  
      DECLARE @cPickPieceType    NVARCHAR( 20) = ''  
      DECLARE @nLLIQty           INT = 0  
      DECLARE @nTOLLIQty         INT = 0  
      DECLARE @fPDCaseCnt        FLOAT  
      DECLARE @cPDUOM            NVARCHAR( 10) = ''  
  
      DECLARE @cPackMethod       NVARCHAR( 20) = '' --PALLET / CASE / PIECE  
      DECLARE @cPackCaseType     NVARCHAR( 20) = '' --SANDWICH / RAINBOW  
      DECLARE @nPackMaxSku       INT = 0 --MAX SKU PER PALLET  
      DECLARE @cPalletType       NVARCHAR( 20) = '' --CHEP / LOSCAM / PLAIN  
  
      DECLARE @cShipLabel          NVARCHAR( 10),  
              @cCartonManifest     NVARCHAR( 10),  
              @cCstLabelSP         NVARCHAR(30)  
  
      DECLARE @cLabelNo          NVARCHAR(20) = ''  
      DECLARE @cPickSlipNo       NVARCHAR(10) = ''  
      DECLARE @cLoadKey          NVARCHAR(10) = ''  
      DECLARE @cOrderKey         NVARCHAR(10) = ''  
      DECLARE @cStorerkey        NVARCHAR(10) = ''  
      DECLARE @nCartonNo         INT  
  
  
      SELECT @cDropID = CaseID  
           , @cOrderKey = Orderkey  
           , @cStorerkey = Storerkey  
      FROM dbo.TaskDetail WITH (NOLOCK)  
      WHERE TaskDetailKey = @cTaskDetailKey  
  
      IF @cOrderKey <> ''  
         SELECT @cConsigneeKey = ConsigneeKey, @cBillToKey = BillToKey, @cOrderType = [Type]  
              , @cPWaveKey = UserDefine09, @cPLoadkey = LoadKey  
         FROM dbo.Orders WITH (NOLOCK) WHERE OrderKey = @cOrderKey  
  
      --Get Pack config  
  
      --Else Check Pack Type by Customer  
      --1. Check if configured by order type (UDF01 = PALLET / CASE, UDF02 = SANDWICH / RAINBOW, UDF03 = MAX SKU PER PALLET)  
      --2. If no point 1 then Check if configured by storer (storerkey = consigneekey 1st, not exist then billtokey)  
      --          (SUSR1 = PALLET / CASE, SUSR2 = SANDWICH / RAINBOW, SUSR3 = MAX SKU PER PALLET)  
      --3. If no point 1/2 then Check if configured by wave/load release (get from:  
--            DispatchPalletPickMethod = 'PALLET' / 'CASE'  
      --            DispatchCasePickMethod   = 'SWPALLET' (SANDWICH PALLET)  
      --                                      /'SWCASE'   (SANDWICH CASE)  
      --                                      /'RBPALLET' (RAINBOW PALLET)  
      --                                      /'RBCASE'   (RAINBOW CASE)  
      --                                      /'PALLET'   (PALLET)  
      --                                      /'CASE'     (CASE)  
      --            DispatchPiecePickMethod  = 'PIECE')  
  
      --1. check if configured by order type  
      IF ISNULL(@cPackMethod,'') = ''  
      BEGIN  
         SET @cCustomerType1 = ''  
         SET @cCustomerType2 = ''  
         SET @cCustomerType3 = ''  
         SET @cCustomerType4 = ''  
         SET @cPackMethod = ''  
  
         SELECT TOP 1 @cCustomerType1 = UDF01  
                    , @cCustomerType2 = UDF02  
                    , @cCustomerType3 = UDF03  
           , @cCustomerType4 = UDF04  
         FROM CODELKUP (NOLOCK)  
         WHERE LISTNAME = 'ORDERTYPE'  
         AND STORERKEY = @cStorerKey  
         AND CODE = @cOrderType  
         AND ISNULL(UDF01,'') IN ('PALLET', 'CASE')  
  
         IF ISNULL(@cCustomerType1,'') <> ''  
            SET @cPackMethod = @cCustomerType1  
      END  
  
      --2. Check if storer configured  
      IF ISNULL(@cPackMethod,'') = ''  
      BEGIN  
         SET @cCustomerType1 = ''  
         SET @cCustomerType2 = ''  
         SET @cCustomerType3 = ''  
         SET @cCustomerType4 = ''  
         SET @cPackMethod = ''  
  
         IF ISNULL(@cConsigneeKey,'') <> ''  
         BEGIN  
            SELECT TOP 1 @cCustomerType1 = SUSR1  
                       , @cCustomerType2 = SUSR2  
                       , @cCustomerType3 = SUSR3  
                       , @cCustomerType4 = PALLET  
            FROM STORER WITH (NOLOCK)  
            WHERE CONSIGNEEFOR = @cStorerKey  
            AND STORERKEY = @cConsigneeKey  
            AND ISNULL(SUSR1,'') IN ('PALLET', 'CASE')  
         END  
  
         IF ISNULL(@cCustomerType1,'') = '' AND ISNULL(@cBillToKey,'') <> ''  
         BEGIN  
            SELECT TOP 1 @cCustomerType1 = SUSR1  
                       , @cCustomerType2 = SUSR2  
                       , @cCustomerType3 = SUSR3  
                       , @cCustomerType4 = PALLET  
            FROM STORER WITH (NOLOCK)  
            WHERE CONSIGNEEFOR = @cStorerKey  
            AND STORERKEY = @cBillToKey  
            AND ISNULL(SUSR1,'') IN ('PALLET', 'CASE')  
      END  
  
         IF ISNULL(@cCustomerType1,'') <> ''  
            SET @cPackMethod = @cCustomerType1  
  
      END  
  
      --3. Check if configured by wave/load release  
      IF ISNULL(@cPackMethod,'') = ''  
      BEGIN  
         SET @cPlanningType = ''  
         SET @cPackMethod = ''  
         SET @cCustomerType2 = ''  
         SET @cCustomerType3 = ''  
         SET @cCustomerType4 = ''  
  
         SELECT TOP 1 @cPlanningType = CODE  
         FROM CODELKUP (NOLOCK)  
         WHERE LISTNAME = 'AU830PLAN'  
         AND STORERKEY = @cStorerKey  
  
         IF ISNULL(@cPlanningType,'') <> ''  
         BEGIN  
            IF ISNULL(@cPlanningType,'') = 'WAVE' AND ISNULL(@cPWaveKey,'') <> ''  
            BEGIN  
               SELECT @cPickPalletType  = DispatchPalletPickMethod  
                    , @cPickCaseType    = DispatchCasePickMethod  
                    , @cPickPieceType   = DispatchPiecePickMethod  
                    , @cCustomerType3   = UserDefine01  
                    , @cCustomerType4   = UserDefine02  
          FROM WAVE WITH (NOLOCK)  
               WHERE WAVEKEY = @cPWaveKey  
            END  
            ELSE IF ISNULL(@cPlanningType,'') = 'LOAD' AND ISNULL(@cPLoadkey,'') <> ''  
            BEGIN  
               SELECT @cPickPalletType  = DispatchPalletPickMethod  
                    , @cPickCaseType    = DispatchCasePickMethod  
                    , @cPickPieceType   = DispatchPiecePickMethod  
                    , @cCustomerType3   = UserDefine01  
                    , @cCustomerType4   = UserDefine02  
               FROM LOADPLAN WITH (NOLOCK)  
               WHERE LOADKEY = @cPLoadkey  
            END  
  
            SET @cPackMethod = ''  
  
            IF @cPickCaseType IN ('SWPALLET' ,'RBPALLET', 'PALLET')  
               SET @cPackMethod = 'PALLET'  
            ELSE IF @cPickCaseType IN ('SWCASE' ,'RBCASE', 'CASE')  
               SET @cPackMethod = 'CASE'  
  
            IF LEFT(@cPickCaseType,2) IN ('SW')  
               SET @cCustomerType2 = 'SANDWICH'  
            ELSE IF LEFT(@cPickCaseType,2) IN ('RB')  
               SET @cCustomerType2 = 'RAINBOW'  
            ELSE  
               SET @cCustomerType2 = ''  
         END  
      END  
  
      IF @nStep = 1 --TAKE DROPID STEP  
      BEGIN  
         IF ISNULL(@cCustomerType4,'') <> ''  
            SET @cExtendedInfo1 = @cCustomerType4  
      END  
  
      IF @nAfterStep = 4  
      BEGIN  
         IF ISNULL(@cCustomerType2,'') IN ('SANDWICH','RAINBOW')  
            SET @cPackCaseType = @cCustomerType2  
         --ELSE  
         --   SET @cPackCaseType = 'RAINBOW' --DEFAULT TO RAINBOW  
  
         IF ISNUMERIC(@cCustomerType3) = 1  
            SET @nPackMaxSku = CAST (@cCustomerType3 AS INT)  
         ELSE  
            SET @nPackMaxSku = 0  
  
         IF @nPackMaxSku > 0  
            SET @cPackMethod = ISNULL(@cPackMethod,'')+' '+CAST(@nPackMaxSku AS NVARCHAR)+'SK'  
  
         SET @cExtendedInfo1 = ISNULL(@cPackCaseType,'')+' '+ISNULL(@cPackMethod,'')  
      END  
   END  
END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_1812ExtInfoAU01] TO [NSQL]
GO