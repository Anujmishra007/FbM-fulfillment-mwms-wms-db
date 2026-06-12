
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/  
/* Store procedure: rdt_GENERATEIDAU1                                   */  
/* Copyright      : Maersk                                              */  
/*                                                                      */  
/* Purpose: Auto generate ID for codelist GENERATEID                    */  
/*                                                                      */  
/* Date        Rev    Author          Purposes                          */  
/* 2024-09-26  1.0.0  SYC067          Created                           */  
/************************************************************************/  
  
CREATE OR ALTER PROCEDURE [RDT].[rdt_GENERATEIDAU1]  
   @nMobile     INT,  
   @nFunc       INT,  
   @nStep       INT,  
   @cLangCode   NVARCHAR( 3),  
   @tExtData    VariableTable READONLY,  
   @cAutoID     NVARCHAR( 18)  OUTPUT,  
   @nErrNo      INT           OUTPUT,  
   @cErrMsg     NVARCHAR( 20) OUTPUT  
AS  
BEGIN  
SET NOCOUNT ON  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS OFF  
SET CONCAT_NULL_YIELDS_NULL OFF  

    DECLARE  @cStorerKey            NVARCHAR( 15)  
            ,@cCounterKey           NVARCHAR( 18)  
            ,@bSuccess              INT  
            ,@nSequenceLen          INT  
            ,@dMinSequence          INT  
            ,@dMaxSequence          INT  
            ,@cPrefix               NVARCHAR( 20)  
            ,@cSuffix               NVARCHAR( 20)  
            ,@cSequenceNo           NVARCHAR( 25)  
            ,@cGeneratedAutoID      NVARCHAR( 65)  
            ,@cIDType               NVARCHAR( 30)  
            ,@cTaskDetailKey        NVARCHAR( 20)  
            ,@cCurrTaskDetailKey    NVARCHAR( 20)  
            ,@cLabelPrinter         NVARCHAR( 20)  
            ,@cPaperPrinter         NVARCHAR( 20)  
            ,@cFacility             NVARCHAR( 10)  
            ,@cUserName             NVARCHAR( 30)  

    SELECT @cStorerKey=storerkey, @cTaskDetailKey = V_TaskDetailKey  
        , @cLabelPrinter = PRINTER, @cPaperPrinter = Printer_Paper  
        , @cFacility = Facility  
        , @cUserName = UserName  
    FROM rdt.rdtmobrec WITH (NOLOCK)  
    WHERE mobile=@nMobile  

    SET @nErrNo = 0
    SET @cErrMsg = ''
    SET @cAutoID = ''

    IF @nFunc IN (1812,1770)  
    BEGIN  
        SET @cCurrTaskDetailKey = ''  

        SELECT TOP 1 @cCurrTaskDetailKey = TaskDetailKey  
        FROM dbo.TASKDETAIL WITH (NOLOCK)  
        WHERE USERKEY = @cUserName  
        AND STATUS = '3'  
        ORDER BY StartTime DESC  

        IF ISNULL(@cCurrTaskDetailKey,'') <> ''  
            AND ISNULL(@cTaskDetailKey,'') <> ISNULL(@cCurrTaskDetailKey,'')  
        BEGIN  
            SET @cTaskDetailKey = @cCurrTaskDetailKey  
        END  

        DECLARE @cCustomerType4 NVARCHAR( 20) = '' --PALLET TYPE: CHEP / LOSCAM / PLAIN  
        DECLARE @cConsigneeKey  NVARCHAR( 15)  
        DECLARE @cBillToKey     NVARCHAR( 15)  
        DECLARE @cPreGenDropID  NVARCHAR( 15)  
        DECLARE @cDropIDLabel   NVARCHAR( 10)  
        DECLARE @cOrderKey      NVARCHAR( 10)  
        DECLARE @cExternOrderkey NVARCHAR( 30)  

        SET @cDropIDLabel = rdt.RDTGetConfig( @nFunc, 'DropIDLabel', @cStorerKey)  
        IF @cDropIDLabel = '0'  
            SET @cDropIDLabel = ''  

        SET @cCustomerType4 = ''  

        SELECT  @cOrderKey = Orderkey  
            --, @cStorerkey = Storerkey  
        FROM dbo.TaskDetail WITH (NOLOCK)  
        WHERE TaskDetailKey = @cTaskDetailKey  

        IF @cOrderKey <> ''  
            SELECT @cConsigneeKey = ConsigneeKey, @cBillToKey = BillToKey--, @cOrderType = [Type]  
                --, @cPWaveKey = UserDefine09, @cPLoadkey = LoadKey  
            FROM dbo.Orders WITH (NOLOCK) WHERE OrderKey = @cOrderKey  

        IF ISNULL(@cConsigneeKey,'') <> ''  
        BEGIN  
            SELECT TOP 1 @cCustomerType4 = PALLET  
            FROM dbo.STORER WITH (NOLOCK)  
            WHERE CONSIGNEEFOR = @cStorerKey  
            AND STORERKEY = @cConsigneeKey  
        END  

        IF ISNULL(@cCustomerType4,'') = '' AND ISNULL(@cBillToKey,'') <> ''  
        BEGIN  
            SELECT TOP 1 @cCustomerType4 = PALLET  
            FROM dbo.STORER WITH (NOLOCK)  
            WHERE CONSIGNEEFOR = @cStorerKey  
            AND STORERKEY = @cBillToKey  
        END  

        SET @cIDType = ''  
        IF ISNULL(@cCustomerType4,'') <> ''  
        BEGIN  
            SET @cIDType = ''  

            SELECT TOP 1 @cIDType = CODE  
            FROM dbo.CODELKUP WITH (NOLOCK)  
            WHERE LISTNAME ='GENERATEID'  
            AND STORERKEY = @cStorerKey  
            AND CHARINDEX(LONG,@cCustomerType4) > 0  
            ORDER BY 1  
            /*  
            IF ISNULL(@cCustomerType4,'') LIKE '%CHEP%' --AND LEFT(@cDropID,4) <> 'PCHE'  
            SET @cIDType = 'PCHE'  
            ELSE IF ISNULL(@cCustomerType4,'') LIKE '%LOSC%' --AND LEFT(@cDropID,4) <> 'PLOS'  
            SET @cIDType = 'PLOS'  
            ELSE IF ISNULL(@cCustomerType4,'') LIKE '%EXP%' --AND LEFT(@cDropID,4) <> 'PEXP'  
            SET @cIDType = 'PEXP'  
            ELSE  
            SET @cIDType = 'PSTD'  
            */  
        END  

        IF ISNULL(@cIDType,'') = ''  
            SET @cIDType = 'PSTD'  --DEFAULT  

        IF ISNULL(@cIDType, N'') = N''  
        BEGIN  
            SET @nErrNo = 269351  
            SET @cErrMsg = [rdt].[rdtGetMessage](@nErrNo, @cLangCode, N'DSP') -- No GenIDType Configuration  
            GOTO Quit  
        END  

        SELECT TOP 1  
            @cPrefix       = ISNULL([UDF01], N''),  
            @cSuffix       = ISNULL([UDF02], N''),  
            @nSequenceLen  = ISNULL(TRY_CAST([Code2] AS INT), 0),  
            @dMinSequence  = ISNULL(TRY_CAST([UDF03] AS INT), 0),  
            @dMaxSequence  = ISNULL(TRY_CAST([UDF04] AS INT), 0)  
        FROM dbo.CODELKUP WITH (NOLOCK)  
        WHERE [ListName]     = N'GENERATEID'  
            AND [Code]        = @cIDType  
            AND [Storerkey]   = @cStorerKey  
        IF @@ROWCOUNT <> 1  
        BEGIN  
            SET @nErrNo = 269352  
            SET @cErrMsg = [rdt].[rdtGetMessage](@nErrNo, @cLangCode, N'DSP') -- No Codelist Configuration  
            GOTO Quit  
        END  

        IF (@nSequenceLen IS NULL OR @nSequenceLen < 1 )  
        BEGIN  
            SET @nErrNo = 269353  
            SET @cErrMsg = [rdt].[rdtGetMessage](@nErrNo, @cLangCode, N'DSP') -- Code2 (Length of Sequence) Error  
            GOTO Quit  
        END  

        IF @dMaxSequence = 0  
            SET @dMaxSequence = ISNULL(TRY_CAST(REPLICATE('9',@nSequenceLen) AS INT), 0)  

        IF ( @dMaxSequence <= @dMinSequence)  
        BEGIN  
            SET @nErrNo = 269354  
            SET @cErrMsg = [rdt].[rdtGetMessage](@nErrNo, @cLangCode, N'DSP') -- -- UDF03 (Min Sequence)/UDF04(Max Sequence) Error  
            GOTO Quit  
        END  

        SET @cCounterKey = RTRIM(@cIDType) + N'_' + @cStorerKey  

        DECLARE @nTranCount INT = @@TRANCOUNT;
        BEGIN TRY
            IF @nTranCount = 0
                BEGIN TRAN;
            ELSE
                SAVE TRAN rdt_GENERATEIDAU1;

            IF EXISTS (
                SELECT 1 FROM dbo.[nCounter] WITH (NOLOCK)
                WHERE [KeyName] = @cCounterKey
                AND ([KeyCount] < @dMinSequence OR [KeyCount] >= @dMaxSequence)
            )
            BEGIN
                DELETE dbo.[nCounter] WITH (ROWLOCK)
                WHERE [KeyName] = @cCounterKey
                IF @@ROWCOUNT = 0
                BEGIN
                    SET @nErrNo = 269357  -- Reset NCounter Failed
                    SET @cErrMsg = [rdt].[rdtGetMessage](@nErrNo, @cLangCode, N'DSP')
                    ;THROW 50001, 'Reset NCounter Failed', 1;
                END
            END

            IF NOT EXISTS( SELECT 1 FROM dbo.[nCounter] WITH (NOLOCK) WHERE [KeyName] = @cCounterKey) 
                AND @dMinSequence > 0
            BEGIN
                INSERT INTO dbo.[nCounter] WITH (ROWLOCK) ([KeyName], [KeyCount]) 
                VALUES (@cCounterKey, @dMinSequence - 1)
            END

            IF @nTranCount = 0
                COMMIT TRAN;
        END TRY
        BEGIN CATCH
            IF XACT_STATE() <> 0
            BEGIN
                IF @nTranCount = 0
                    ROLLBACK TRAN;
                ELSE
                    ROLLBACK TRAN rdt_GENERATEIDAU1;
            END
             IF @nErrNo = 0
                SET @nErrNo = 269358  -- Reset NCounter Failed
            SET @cErrMsg = [rdt].[rdtGetMessage](@nErrNo, @cLangCode, N'DSP')
            GOTO Quit
        END CATCH

        SET @bSuccess = 1  
        EXECUTE [dbo].[nspg_getkey]  
              @cCounterKey  
            , @nSequenceLen  
            , @cSequenceNo       OUTPUT  
            , @bSuccess          OUTPUT  
            , @nErrNo            OUTPUT  
            , @cErrMsg           OUTPUT  
        IF @bSuccess <> 1  
        BEGIN  
            SET @nErrNo = 269356  
            SET @cErrMsg = [rdt].[rdtGetMessage](@nErrNo, @cLangCode, N'DSP') -- Getkey Error  
            GOTO Quit  
        END  

        SET @cGeneratedAutoID = LTRIM(RTRIM(ISNULL(@cPrefix, N''))) + ISNULL(@cSequenceNo, N'') + LTRIM(RTRIM(ISNULL(@cSuffix, N'')))
        IF LEN(@cGeneratedAutoID) > 18
        BEGIN
            SET @nErrNo = 269355
            SET @cErrMsg = [rdt].[rdtGetMessage](@nErrNo, @cLangCode, N'DSP') -- Generated ID exceeds output length
            GOTO Quit
        END

        SET @cAutoID = @cGeneratedAutoID  
        --SET @cOutField01 = @cAutoID  

        --Submit Print Job for DropID  
        IF ISNULL(@cLabelPrinter,'') <> ''  AND ISNULL(@cAutoID,'') <> ''  
        BEGIN  
            IF @cDropIDLabel <> ''  
            BEGIN  
            --Standard Print  
            --SET @cExternOrderkey = ''  
            --SELECT @cExternOrderkey = ExternOrderKey  
            --FROM ORDERS WITH (NOLOCK)  
            --WHERE STORERKEY = @cStorerKey  
            --AND ORDERKEY = @cOrderkey  
            -- Common params  
            DECLARE @tDropIDLabel AS VariableTable  

            INSERT INTO @tDropIDLabel (Variable, Value) VALUES  
                ( '@cStorerKey', @cStorerKey),  
                ( '@cDropID',    @cAutoID) ,  
                ( '@cAdditionalInfo1',  @cOrderkey)  

            -- Print label  
            EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, '1', @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,  
                @cDropIDLabel, -- Report type  
                @tDropIDLabel, -- Report params  
                'rdt_GENERATEIDAU1',  
                @nErrNo  OUTPUT,  
                @cErrMsg OUTPUT  
            IF @nErrNo <> 0  
               GOTO Quit  
            END  
        END  
    END  

    Quit:  
END
GO

GRANT EXECUTE ON [RDT].[rdt_GENERATEIDAU1] TO NSQL 
GO   

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
