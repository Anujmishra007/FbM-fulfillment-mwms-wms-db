SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/  
/* Store procedure: rdt_1812ExtValAU01                                  */  
/* Purpose: Validate DropID                                             */  
/*                                                                      */  
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date         Author    Ver.  Purposes                                */  
/* 2026-04-03   NYE018    1.0   FCR-11492 Created                       */
/* 2026-04-05   NYE018    1.1   FCR-12113 Add Step 5 validation         */
/************************************************************************/  
  
CREATE OR ALTER PROCEDURE [RDT].[rdt_1812ExtValAU01]  
    @nMobile         INT  
   ,@nFunc           INT  
   ,@cLangCode       NVARCHAR( 3)  
   ,@nStep           INT  
   ,@nInputKey       INT  
   ,@cTaskdetailKey  NVARCHAR( 10)  
   ,@cDropID         NVARCHAR( 20)  
   ,@nQTY            INT  
   ,@cToLOC          NVARCHAR( 10)  
   ,@nErrNo          INT           OUTPUT  
   ,@cErrMsg         NVARCHAR( 20) OUTPUT  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   -- TM Pallet Pick  
   IF @nFunc = 1812  
   BEGIN  
      IF @nStep = 1 -- DropID  
      BEGIN  
         IF @nInputKey = 1 -- ENTER  
         BEGIN  
            -- Check DropID  
            IF @cDropID = ''  
            BEGIN  
               SET @nErrNo = 263151  
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Need DropID  
               EXEC rdt.rdtSetFocusField @nMobile, 4 -- DropID  
               GOTO Quit  
            END  
  
            -- Get storer  
            DECLARE @cStorerKey NVARCHAR(15)  
            DECLARE @cOrderKey  NVARCHAR(10) = ''  
            SELECT @cStorerKey = StorerKey, @cOrderKey = OrderKey FROM TaskDetail WITH (NOLOCK) WHERE TaskDetailKey = @cTaskDetailKey  
  
            -- Check duplicate  
            IF EXISTS( SELECT 1 FROM PickDetail WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND DropID = @cDropID AND Status < '9'  
                       AND Orderkey <> @cOrderKey)  
            BEGIN  
               SET @nErrNo = 263152  
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- DropID used  
               EXEC rdt.rdtSetFocusField @nMobile, 4 -- DropID  
               GOTO Quit  
            END  
  
  
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
            DECLARE @cLoadKey     NVARCHAR(10) = ''  
            --DECLARE @cStorerkey        NVARCHAR(10) = ''  
            DECLARE @nCartonNo         INT  
  
  
            SELECT  @cOrderKey = Orderkey  
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
  
            IF ISNULL(@cCustomerType4,'') <> ''  
            BEGIN  
               IF NOT EXISTS ( SELECT TOP 1 1  
                               FROM CODELKUP (NOLOCK)  
                               WHERE LISTNAME ='GENERATEID'  
                               AND STORERKEY = @cStorerKey  
                               AND CHARINDEX(LONG,@cCustomerType4) > 0  
                               AND CHARINDEX(CODE,@cDropID) > 0  
                             )  
               BEGIN  
                  SET @nErrNo = 263153  
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- INVALID DROPID  
                  EXEC rdt.rdtSetFocusField @nMobile, 4 -- DropID  
                  GOTO Quit  
               END  
            END  
  
            /*  
            IF LEFT(@cDropID,4) NOT IN ('PEXP','PCHE','PLOS','PSTD')  
            BEGIN  
               SET @nErrNo = 56501  
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- INVALID DROPID  
               EXEC rdt.rdtSetFocusField @nMobile, 4 -- DropID  
               GOTO Quit  
            END  
  
            IF ISNULL(@cCustomerType4,'') LIKE '%CHEP%' AND ISNULL(@cCustomerType4,'') LIKE '%LOSC%'  
            BEGIN  
               IF LEFT(@cDropID,4) NOT IN ('PLOS','PCHE')  
               BEGIN  
                  SET @nErrNo = 56501  
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- INVALID DROPID  
                  EXEC rdt.rdtSetFocusField @nMobile, 4 -- DropID  
                  GOTO Quit  
               END  
            END  
            ELSE  
            BEGIN  
               IF ISNULL(@cCustomerType4,'') LIKE '%CHEP%' AND LEFT(@cDropID,4) <> 'PCHE'  
               BEGIN  
                  SET @nErrNo = 56501  
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- INVALID DROPID  
                  EXEC rdt.rdtSetFocusField @nMobile, 4 -- DropID  
                  GOTO Quit  
               END  
  
               IF ISNULL(@cCustomerType4,'') LIKE '%LOSC%' AND LEFT(@cDropID,4) <> 'PLOS'  
               BEGIN  
                  SET @nErrNo = 56501  
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- INVALID DROPID  
                  EXEC rdt.rdtSetFocusField @nMobile, 4 -- DropID  
                  GOTO Quit  
               END  
            END  
  
            IF ISNULL(@cCustomerType4,'') LIKE '%EXP%' AND LEFT(@cDropID,4) <> 'PEXP'  
            BEGIN  
               SET @nErrNo = 56501  
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- INVALID DROPID  
               EXEC rdt.rdtSetFocusField @nMobile, 4 -- DropID  
               GOTO Quit  
            END  
            */  
  
         END
      END

      IF @nStep = 5 -- Continue Next Task / Close Pallet
      BEGIN
         IF @nInputKey = 1 -- ENTER (Option 1 = CONT NEXT TASK)
         BEGIN
            -- Get OrderKey from current task
            DECLARE @cCurrentOrderKey NVARCHAR(10) = ''
            SELECT @cCurrentOrderKey = OrderKey
            FROM dbo.TaskDetail WITH (NOLOCK)
            WHERE TaskDetailKey = @cTaskDetailKey

            -- Check if there are other FCP tasks with same OrderKey
            IF NOT EXISTS (
               SELECT 1
               FROM dbo.TaskDetail WITH (NOLOCK)
               WHERE OrderKey = @cCurrentOrderKey
                 AND TaskType = 'FCP'
                 AND Status = '0'
                 AND TaskDetailKey <> @cTaskDetailKey
            )
            BEGIN
               SET @nErrNo = 263154
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- No more tasks. Close Pallet.
               GOTO Quit
            END
         END
      END
   END
   GOTO Quit

Quit:

END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_1812ExtValAU01] TO [NSQL]
GO