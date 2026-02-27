SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/  
/* Store procedure: rdt_732ExtendedCfm01                                      */  
/* Copyright      : MAERSK                                                    */  
/*                                                                            */  
/* Purpose: Update CCDetail                                                   */  
/*                                                                            */  
/* Called from: rdtfnc_SimpleCC                                               */  
/*                                                                            */  
/* Modifications log:                                                         */  
/*                                                                            */  
/* Date        Rev  Author      Purposes                                      */  
/* 2025-03-07  1.0  James       FCR-2054. Created                             */  
/******************************************************************************/  
  
CREATE OR ALTER PROCEDURE [RDT].[rdt_732ExtendedCfm01]  
   @nMobile       INT,  
   @nFunc         INT,  
   @cLangCode     NVARCHAR( 3),  
   @nStep         INT,
   @nInputKey     INT,
   @cFacility     NVARCHAR( 5),
   @cStorerKey    NVARCHAR( 15),
   @cCCKey        NVARCHAR( 10),
   @cCCSheetNo    NVARCHAR( 10),
   @nCountNo      INT,
   @cLOC          NVARCHAR( 10),            
   @cID           NVARCHAR( 18),
   @cSKU          NVARCHAR( 20),
   @nQty          INT,   
   @cLottable01   NVARCHAR( 18),  
   @cLottable02   NVARCHAR( 18),  
   @cLottable03   NVARCHAR( 18),  
   @dLottable04   DATETIME,  
   @dLottable05   DATETIME,  
   @cLottable06   NVARCHAR( 30),  
   @cLottable07   NVARCHAR( 30),  
   @cLottable08   NVARCHAR( 30),  
   @cLottable09   NVARCHAR( 30),  
   @cLottable10   NVARCHAR( 30),  
   @cLottable11   NVARCHAR( 30),  
   @cLottable12   NVARCHAR( 30),  
   @dLottable13   DATETIME,  
   @dLottable14   DATETIME,  
   @dLottable15   DATETIME,  
   @tCCDtlCfm     VARIABLETABLE READONLY,
   @nErrNo        INT           OUTPUT,  
   @cErrMsg       NVARCHAR( 20) OUTPUT
AS
BEGIN  
   SET NOCOUNT ON    
   SET QUOTED_IDENTIFIER OFF    
   SET ANSI_NULLS OFF    
   SET CONCAT_NULL_YIELDS_NULL OFF    
  
   DECLARE @nTranCount     INT  
   DECLARE @bsuccess       INT
   DECLARE @nQTY_PD        INT
   DECLARE @cLottableCode  NVARCHAR( 30)
   DECLARE @cSQL           NVARCHAR( MAX)
   DECLARE @cSQLParam      NVARCHAR( MAX)
   DECLARE @cWhere         NVARCHAR( MAX)
   DECLARE @cCCDetailKey   NVARCHAR(10) = ''    
   DECLARE @curCCD         CURSOR  
   DECLARE @debug          INT = 0
   DECLARE @nLottableNo    INT
   DECLARE @cLottableNo    NVARCHAR( 2)
   DECLARE @cLottableVar   NVARCHAR( 15)
   DECLARE @cLottableCol   NVARCHAR( 15)
   DECLARE @cWhere1        NVARCHAR( MAX)
   DECLARE @cWhere2        NVARCHAR( MAX)
   DECLARE @cUserName      NVARCHAR( 18)
   DECLARE @cCaptureID     NVARCHAR( 1)
   DECLARE @curUPD_ID      CURSOR
   DECLARE @cCounted_Cnt1  NVARCHAR( 1) = '0'
   DECLARE @cCounted_Cnt2  NVARCHAR( 1) = '0'
   DECLARE @cCounted_Cnt3  NVARCHAR( 1) = '0'

   SELECT 
      @cUserName = UserName,
      @cCaptureID = V_String26
   FROM rdt.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   SET @nTranCount = @@TRANCOUNT  
  
   BEGIN TRAN  
   SAVE TRAN rdt_732ExtendedCfm01  

   -- Capture ID only, copy systemqty -> Qty
   IF @cCaptureID = '2'
   BEGIN
      IF EXISTS( SELECT 1
                 FROM dbo.CCDetail WITH (NOLOCK)
                 WHERE CCKey = @cCCKey
                 AND   CCSheetNo = CASE WHEN ISNULL( @cCCSheetNo, '') = '' THEN CCSheetNo ELSE @cCCSheetNo END
                 AND   LOC = @cLOC
                 AND   ID = @cID
                 AND   Storerkey = @cStorerKey
                 AND   Counted_Cnt1 = CASE WHEN @nCountNo = 1 THEN 1 ELSE Counted_Cnt1 END
                 AND   Counted_Cnt2 = CASE WHEN @nCountNo = 2 THEN 1 ELSE Counted_Cnt2 END
                 AND   Counted_Cnt3 = CASE WHEN @nCountNo = 3 THEN 1 ELSE Counted_Cnt3 END)
      BEGIN        
         SET @nErrNo = 234951        
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  --ID Counted
         GOTO RollBackTran         
      END    

      SET @curUPD_ID = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
      SELECT CCDetailKey
      FROM dbo.CCDetail WITH (NOLOCK)
      WHERE CCKey = @cCCKey
      AND   CCSheetNo = CASE WHEN ISNULL( @cCCSheetNo, '') = '' THEN CCSheetNo ELSE @cCCSheetNo END
      AND   LOC = @cLOC
      AND   ID = @cID
      AND   Storerkey = @cStorerKey
      AND   Counted_Cnt1 = CASE WHEN @nCountNo = 1 THEN 0 ELSE Counted_Cnt1 END
      AND   Counted_Cnt2 = CASE WHEN @nCountNo = 2 THEN 0 ELSE Counted_Cnt2 END
      AND   Counted_Cnt3 = CASE WHEN @nCountNo = 3 THEN 0 ELSE Counted_Cnt3 END
      ORDER BY 1
      OPEN @curUPD_ID
      FETCH NEXT FROM @curUPD_ID INTO @cCCDetailKey
      -- If nothing fetched, insert a new record
      -- Default qty = 1, user will check this cc record if qty adnormal (qty = 1)
      IF @@FETCH_STATUS <> 0
      BEGIN    
         EXECUTE dbo.nspg_GetKey                                        
            @KeyName       = 'CCDETAILKEY',                                    
            @fieldlength   = 10 ,                                          
            @keystring     = @cCCDetailKey   OUTPUT,                         
            @b_success     = @bsuccess       OUTPUT,                             
            @n_err         = @nErrNo         OUTPUT,                                   
            @c_errmsg      = @cErrMsg        OUTPUT                                
              
         IF @bsuccess <> 1        
         BEGIN        
            SET @nErrNo = 234952        
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  --GetKey Fail  
            GOTO RollBackTran         
         END    
          
         SELECT TOP 1
            @cCCSheetNo = CCSheetNo
         FROM dbo.CCDetail WITH (NOLOCK)
         WHERE CCKey = @cCCKey
         AND   Storerkey = @cStorerKey
         AND   LOC = @cLOC
         ORDER BY 1
         
         IF ISNULL(RTRIM(@cCCSheetNo), '') = ''    
         BEGIN    
            EXECUTE dbo.nspg_GetKey                
               @KeyName       = 'CCSheetNo',                        
               @fieldlength   = 10 ,                                
               @keystring     = @cCCSheetNo  OUTPUT,          
               @b_success     = @bsuccess    OUTPUT,           
               @n_err         = @nErrNo      OUTPUT,          
               @c_errmsg      = @cErrMsg     OUTPUT            
                 
            IF @bsuccess <> 1        
            BEGIN        
               SET @nErrNo = 234953  
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  --GetKey Fail  
               GOTO RollBackTran         
            END                   
         END    

         -- 1 pallet 1 set of lottable
         SELECT TOP 1
            @cLottable01 = Lottable01, 
            @cLottable02 = Lottable02, 
            @cLottable03 = Lottable03, 
            @dLottable04 = Lottable04, 
            @cLottable06 = Lottable06, 
            @cLottable07 = Lottable07, 
            @cLottable08 = Lottable08, 
            @cLottable09 = Lottable09, 
            @cLottable10 = Lottable10,
            @cLottable11 = Lottable11, 
            @cLottable12 = Lottable12, 
            @dLottable13 = Lottable13, 
            @dLottable14 = Lottable14, 
            @dLottable15 = Lottable15
         FROM dbo.CCDetail WITH (NOLOCK)
         WHERE CCKey = @cCCKey
         AND   Storerkey = @cStorerKey
         AND   ID = CASE WHEN ISNULL( @cID, '') = '' THEN ID ELSE @cID END
         ORDER BY 1

         SET @cSKU = '000000001' -- Set dummy sku here, logi report need to have sku to link

         IF ISNULL(@nCountNo,'') = '1'    
         BEGIN    
            INSERT INTO CCDETAIL (  
               CCKey, CCDetailKey, CCSheetNo, TagNo, Storerkey, Sku, Lot, Loc, Id, SystemQty, Qty,   
               Lottable01, Lottable02, Lottable03, Lottable04, Lottable05, 
               Lottable06, Lottable07, Lottable08, Lottable09, Lottable10,
               Lottable11, Lottable12, Lottable13, Lottable14, Lottable15,
               FinalizeFlag, Status, Counted_Cnt1)    
            VALUES (  
               @cCCKey, @cCCDetailKey, @cCCSheetNo, '', @cStorerKey, @cSKU, '', @cLOC, @cID, 0, 1,   
               @cLottable01, @cLottable02, @cLottable03, @dLottable04, GETDATE(),    
               @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
               @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
               'N', '4', '1')    
            IF @@ERROR <> 0        
            BEGIN        
               SET @nErrNo = 234954       
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  --INS CCDtl Fail      
               GOTO RollBackTran        
            END       
         END               
         ELSE IF ISNULL(@nCountNo,'') = '2'    
         BEGIN       
            INSERT INTO CCDETAIL (  
               CCKey, CCDetailKey, CCSheetNo, TagNo, Storerkey, Sku, Lot, Loc, Id, SystemQty, Qty_Cnt2,   
               Lottable01, Lottable02, Lottable03, Lottable04, Lottable05, 
               Lottable06, Lottable07, Lottable08, Lottable09, Lottable10,
               Lottable11, Lottable12, Lottable13, Lottable14, Lottable15,
               FinalizeFlag, Status, Counted_Cnt2)    
            VALUES (  
               @cCCKey, @cCCDetailKey, @cCCSheetNo, '', @cStorerKey, @cSKU, '', @cLOC, @cID, 0, 1,   
               @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,    
               @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
               @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
               'N', '4', '1')    
            IF @@ERROR <> 0        
            BEGIN        
               SET @nErrNo = 234955        
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  --INS CCDtl Fail      
               GOTO RollBackTran        
            END               
         END     
         ELSE IF ISNULL(@nCountNo,'') = '3'    
         BEGIN       
            INSERT INTO CCDETAIL (  
               CCKey, CCDetailKey, CCSheetNo, TagNo, Storerkey, Sku, Lot, Loc, Id, SystemQty, Qty_Cnt3,   
               Lottable01, Lottable02, Lottable03, Lottable04, Lottable05, 
               Lottable06, Lottable07, Lottable08, Lottable09, Lottable10,
               Lottable11, Lottable12, Lottable13, Lottable14, Lottable15,
               FinalizeFlag, Status, Counted_Cnt3)    
            VALUES (@cCCKey, @cCCDetailKey, @cCCSheetNo, '', @cStorerKey, @cSKU, '', @cLOC, @cID, 0, 1,   
               @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,    
               @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
               @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
               'N', '4', '1')    
            IF @@ERROR <> 0        
            BEGIN        
               SET @nErrNo = 234956        
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  --INS CCDtl Fail      
               GOTO RollBackTran        
            END               
         END       
      END
      ELSE
      BEGIN
         -- Otherwise, process records
         WHILE @@FETCH_STATUS = 0
         BEGIN
            IF @nCountNo = 1
            BEGIN
               UPDATE dbo.CCDetail SET
                  [Status]  = '2',
                  Qty = SystemQty,
                  Counted_Cnt1 = '1',
                  EditWho = @cUserName,
                  EditDate = GETDATE()
               WHERE CCDetailKey = @cCCDetailKey

               IF @@ERROR <> 0
               BEGIN    
                  SET @nErrNo = 234957  
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  --UPD CCDtl Fail  
                  GOTO RollBackTran    
               END    
            END
            ELSE IF @nCountNo = 2
            BEGIN
               UPDATE dbo.CCDetail SET
                  [Status]  = '2',
                  Qty_Cnt2 = SystemQty,
                  Counted_Cnt2 = '1',
                  EditWho = @cUserName,
                  EditDate = GETDATE()
               WHERE CCDetailKey = @cCCDetailKey

               IF @@ERROR <> 0
               BEGIN    
                  SET @nErrNo = 234958  
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  --UPD CCDtl Fail  
                  GOTO RollBackTran    
               END    
            END
            ELSE IF @nCountNo = 3
            BEGIN
               UPDATE dbo.CCDetail SET
                  [Status]  = '2',
                  Qty_Cnt3 = SystemQty,
                  Counted_Cnt3 = '1',
                  EditWho = @cUserName,
                  EditDate = GETDATE()
               WHERE CCDetailKey = @cCCDetailKey
               
               IF @@ERROR <> 0
               BEGIN    
                  SET @nErrNo = 234959  
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  --UPD CCDtl Fail  
                  GOTO RollBackTran    
               END    
            END

            FETCH NEXT FROM @curUPD_ID INTO @cCCDetailKey
         END
      END
      CLOSE @curUPD_ID
      DEALLOCATE @curUPD_ID
   END
   ELSE
   BEGIN
      SELECT @cLottableCode = LottableCode
      FROM dbo.SKU WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
      AND   Sku = @cSKU
   
      -- Temp table for lottable
      DECLARE @tLC TABLE
      (
         RowRef      INT           IDENTITY( 1,1),
         LottableNo  INT           NOT NULL,
         Visible     NVARCHAR(  1) NOT NULL,
         Editable    NVARCHAR(  1) NOT NULL,
         Required    NVARCHAR(  1) NOT NULL,
         Sequence    INT           NOT NULL,
         Description NVARCHAR( 20) NOT NULL,
         FormatSP    NVARCHAR( 50) NOT NULL
      )

      SET @cWhere = ''

      IF @cLottableCode = ''
         GOTO Quit

      -- If function specific lottablecode not setup, use generic one
      IF @nFunc > 0
         IF NOT EXISTS( SELECT TOP 1 1
            FROM rdt.rdtLottableCode WITH (NOLOCK)
            WHERE LottableCode = @cLottableCode
               AND Function_ID = @nFunc
               AND StorerKey = @cStorerKey)
            SET @nFunc = 0

      INSERT INTO @tLC (LottableNo, Visible, Editable, Required, Sequence, Description, FormatSP)
      SELECT 
         LottableNo, Visible, Editable, Required, Sequence, Description, FormatSP
      FROM rdt.rdtLottableCode WITH (NOLOCK)
      WHERE LottableCode = @cLottableCode
         AND Function_ID = @nFunc
         AND StorerKey = @cStorerKey
         AND Visible = '1'
      ORDER BY Sequence

      DECLARE @curLC CURSOR
      SET @curLC = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT LottableNo
         FROM @tLC
         ORDER BY Sequence
      OPEN @curLC
      FETCH NEXT FROM @curLC INTO @nLottableNo

      -- Loop lottable display on screen
      WHILE @@FETCH_STATUS = 0
      BEGIN
         -- Get lottable
         SET @cLottableNo = RIGHT( '0' + CAST( @nLottableNo AS NVARCHAR(2)), 2)
         SET @cLottableCol = 'Lottable' + @cLottableNo
         SET @cLottableVar = CASE WHEN @nLottableNo IN (4, 5, 13, 14, 15) THEN '@d' ELSE '@c' END + 'Lottable' + @cLottableNo

         SET @cLottableCol = @cLottableCol + CASE WHEN @nCountNo = 2 THEN '_CNT2' 
                                                  WHEN @nCountNo = 3 THEN '_CNT3' 
                                                  ELSE '' END

         -- Construct SQL clause
         SET @cWhere = @cWhere + ' AND ' + @cLottableCol + ' = ' + @cLottableVar

         FETCH NEXT FROM @curLC INTO @nLottableNo
      END

      -- Construct remain SQL clause
      IF @cWhere <> ''
         SET @cWhere = SUBSTRING( @cWhere, 5, LEN( @cWhere)) -- Remove leading " AND "
      
      IF @debug = 1      
         SELECT @cWhere '@cWhere'

      -- Open cursor
      SET @cSQL =
         ' SET @curCCD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR ' +  
         ' SELECT CCDetailKey, SystemQty ' +  
         ' FROM dbo.CCDetail WITH (NOLOCK) ' +  
         ' WHERE Storerkey = @cStorerKey ' +   
         ' AND   CCKey = @cCCKey ' +  
         ' AND   LOC = @cLOC ' +
         ' AND   SKU = @cSKU ' +   
         ' AND   ID = ' + CASE WHEN ISNULL( @cID, '') = '' THEN ' ID' ELSE '@cID ' END +
         CASE WHEN @cWhere = '' THEN '' ELSE ' AND ' + @cWhere END
      SET @cSQL = @cSQL + ' ORDER BY CCDetailKey'
      SET @cSQL = @cSQL + ' OPEN @curCCD'

      SET @cSQLParam =
         ' @curCCD      CURSOR OUTPUT, ' +
         ' @cStorerKey  NVARCHAR( 15), ' +
         ' @cCCKey      NVARCHAR( 10), ' +
         ' @cLOC        NVARCHAR( 10), ' +
         ' @cID         NVARCHAR( 18), ' +
         ' @cSKU        NVARCHAR( 20), ' +
         ' @cLottable01 NVARCHAR( 18), ' +
         ' @cLottable02 NVARCHAR( 18), ' +
         ' @cLottable03 NVARCHAR( 18), ' +
         ' @dLottable04 DATETIME,      ' +
         ' @dLottable05 DATETIME,      ' +
         ' @cLottable06 NVARCHAR( 30), ' +
         ' @cLottable07 NVARCHAR( 30), ' +
         ' @cLottable08 NVARCHAR( 30), ' +
         ' @cLottable09 NVARCHAR( 30), ' +
         ' @cLottable10 NVARCHAR( 30), ' +
         ' @cLottable11 NVARCHAR( 30), ' +
         ' @cLottable12 NVARCHAR( 30), ' +
         ' @dLottable13 DATETIME,      ' +
         ' @dLottable14 DATETIME,      ' +
         ' @dLottable15 DATETIME       '

      EXEC sp_ExecuteSQL @cSQL, @cSQLParam, @curCCD OUTPUT, @cStorerKey, @cCCKey, @cLOC, @cID, @cSKU, 
         @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
         @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
         @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15

      IF @debug = 1      
         SELECT @cSQL '@cSQL', @cSQLParam '@cSQLParam'

      FETCH NEXT FROM @curCCD INTO @cCCDetailKey, @nQTY_PD  
      WHILE @@FETCH_STATUS = 0    
      BEGIN    
         IF @nQTY_PD = @nQty    
         BEGIN    
            UPDATE dbo.CCDEtail SET  
               Qty      = CASE WHEN @nCountNo = '1' THEN Qty  + @nQty ELSE Qty  END,  
               Qty_Cnt2 = CASE WHEN @nCountNo = '2' THEN Qty_Cnt2 + @nQty ELSE Qty_Cnt2 END,  
               Qty_Cnt3 = CASE WHEN @nCountNo = '3' THEN Qty_Cnt3 + @nQty ELSE Qty_Cnt3 END,  
               Status  = '2',  
               Counted_Cnt1 = CASE WHEN @nCountNo = '1' THEN '1' ELSE Counted_Cnt1 END,  
               Counted_Cnt2 = CASE WHEN @nCountNo = '2' THEN '1' ELSE Counted_Cnt2 END,  
               Counted_Cnt3 = CASE WHEN @nCountNo = '3' THEN '1' ELSE Counted_Cnt3 END,
               EditWho = @cUserName,
               EditDate = GETDATE()
            WHERE CCDetailKey = @cCCDetailKey  
    
            IF @@ERROR <> 0     
            BEGIN    
               SET @nErrNo = 234960  
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  --UPD CCDtl Fail  
               GOTO RollBackTran    
            END    
         END    
         ELSE    
         IF @nQty > @nQTY_PD    
         BEGIN    
            UPDATE dbo.CCDEtail SET  
               Qty      = CASE WHEN @nCountNo = '1' THEN Qty  + @nQTY_PD ELSE Qty  END,  
               Qty_Cnt2 = CASE WHEN @nCountNo = '2' THEN Qty_Cnt2  + @nQTY_PD ELSE Qty_Cnt2 END,  
               Qty_Cnt3 = CASE WHEN @nCountNo = '3' THEN Qty_Cnt3  + @nQTY_PD ELSE Qty_Cnt3 END,  
               Status  = '2',  
               Counted_Cnt1 = CASE WHEN @nCountNo = '1' THEN '1' ELSE Counted_Cnt1 END,  
               Counted_Cnt2 = CASE WHEN @nCountNo = '2' THEN '1' ELSE Counted_Cnt2 END,  
               Counted_Cnt3 = CASE WHEN @nCountNo = '3' THEN '1' ELSE Counted_Cnt3 END,
               EditWho = @cUserName,
               EditDate = GETDATE()  
            WHERE CCDetailKey = @cCCDetailKey  
    
            IF @@ERROR <> 0     
            BEGIN    
               SET @nErrNo = 234961  
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  --UPD CCDtl Fail  
               GOTO RollBackTran    
            END     
         END    
         ELSE    
         IF @nQty < @nQTY_PD AND @nQty > 0    
         BEGIN    
            UPDATE dbo.CCDEtail SET  
               Qty      = CASE WHEN @nCountNo = '1' THEN Qty  + @nQty ELSE Qty  END,  
               Qty_Cnt2 = CASE WHEN @nCountNo = '2' THEN Qty_Cnt2 + @nQty ELSE Qty_Cnt2 END,  
               Qty_Cnt3 = CASE WHEN @nCountNo = '3' THEN Qty_Cnt3 + @nQty ELSE Qty_Cnt3 END,  
               Status  = '2',  
               Counted_Cnt1 = CASE WHEN @nCountNo = '1' THEN '1' ELSE Counted_Cnt1 END,  
               Counted_Cnt2 = CASE WHEN @nCountNo = '2' THEN '1' ELSE Counted_Cnt2 END,  
               Counted_Cnt3 = CASE WHEN @nCountNo = '3' THEN '1' ELSE Counted_Cnt3 END,
               EditWho = @cUserName,
               EditDate = GETDATE()  
            WHERE CCDetailKey = @cCCDetailKey  
    
             IF @@ERROR <> 0     
             BEGIN    
                SET @nErrNo = 234962  
                SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  --UPD CCDtl Fail  
                GOTO RollBackTran    
             END     
         END    
         IF @nQty = 0 -- Treat as Counted when Qty = 0 and still have same SKU and Loc not counted.  
         BEGIN  
            UPDATE dbo.CCDEtail SET  
               Status  = '2',  
               Counted_Cnt1 = CASE WHEN @nCountNo = '1' THEN '1' ELSE Counted_Cnt1 END,  
               Counted_Cnt2 = CASE WHEN @nCountNo = '2' THEN '1' ELSE Counted_Cnt2 END,  
               Counted_Cnt3 = CASE WHEN @nCountNo = '3' THEN '1' ELSE Counted_Cnt3 END,
               EditWho = @cUserName,
               EditDate = GETDATE()  
            WHERE CCDetailKey = @cCCDetailKey  
    
            IF @@ERROR <> 0     
            BEGIN    
               SET @nErrNo = 234963  
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  --UPD CCDtl Fail  
               GOTO RollBackTran    
            END     
         END  
    
         SET @nQty = @nQty - @nQTY_PD   
        
         IF @nQty < 0   
         BEGIN  
            SET @nQty = 0   
         END  
    
         FETCH NEXT FROM @curCCD INTO @cCCDetailKey, @nQTY_PD  
      END -- While Loop for PickDetail Key    

     
      IF @nQty > 0 AND @cCCDetailKey <> '' -- Update Remaining Qty to last of the CCDetail line with Same Loc and SKU  
      BEGIN  
         UPDATE dbo.CCDEtail WITH (ROWLOCK)  
         SET Qty      = CASE WHEN @nCountNo = '1' THEN Qty  + @nQty ELSE Qty  END  
         , Qty_Cnt2 = CASE WHEN @nCountNo = '2' THEN Qty_Cnt2 + @nQty ELSE Qty_Cnt2 END  
         , Qty_Cnt3 = CASE WHEN @nCountNo = '3' THEN Qty_Cnt3 + @nQty ELSE Qty_Cnt3 END  
         , Status  = '2'  
         , Counted_Cnt1 = CASE WHEN @nCountNo = '1' THEN '1' ELSE Counted_Cnt1 END  
         , Counted_Cnt2 = CASE WHEN @nCountNo = '2' THEN '1' ELSE Counted_Cnt2 END  
         , Counted_Cnt3 = CASE WHEN @nCountNo = '3' THEN '1' ELSE Counted_Cnt3 END
         , EditWho = @cUserName
         , EditDate = GETDATE()
         WHERE CCKey = @cCCKey  
         AND CCDetailKey = @cCCDetailKey  
    
         IF @@ERROR <> 0     
         BEGIN    
            SET @nErrNo = 234964  
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  --UPD CCDtl Fail  
            GOTO RollBackTran    
         END      
      END  

      IF NOT EXISTS ( SELECT 1  
                     FROM dbo.CCDetail WITH (NOLOCK)  
                     WHERE CCKey = @cCCKey   
                     AND   Storerkey = @cStorerKey  
                     AND   SKU = @cSKU   
                     AND   LOC = @cLOC  
                     AND   ID = CASE WHEN ISNULL (@cID, '') = '' THEN ID ELSE @cID END)  
      BEGIN    
         EXECUTE dbo.nspg_GetKey                                        
            @KeyName       = 'CCDETAILKEY',                                    
            @fieldlength   = 10 ,                                          
            @keystring     = @cCCDetailKey   OUTPUT,                         
            @b_success     = @bsuccess       OUTPUT,                             
            @n_err         = @nErrNo         OUTPUT,                                   
            @c_errmsg      = @cErrMsg        OUTPUT                                
              
         IF @bsuccess <> 1        
         BEGIN        
            SET @nErrNo = 234965        
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  --GetKey Fail  
            GOTO RollBackTran         
         END    
          
         SELECT TOP 1
            @cCCSheetNo = CCSheetNo
         FROM dbo.CCDetail WITH (NOLOCK)
         WHERE CCKey = @cCCKey
         AND   Storerkey = @cStorerKey
         AND   LOC = @cLOC
         ORDER BY 1
         
         IF ISNULL(RTRIM(@cCCSheetNo), '') = ''    
         BEGIN    
            EXECUTE dbo.nspg_GetKey                
               @KeyName       = 'CCSheetNo',                        
               @fieldlength   = 10 ,                                
               @keystring     = @cCCSheetNo  OUTPUT,          
               @b_success     = @bsuccess    OUTPUT,           
               @n_err         = @nErrNo      OUTPUT,          
               @c_errmsg      = @cErrMsg     OUTPUT            
                 
            IF @bsuccess <> 1        
            BEGIN        
               SET @nErrNo = 234966  
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  --GetKey Fail  
               GOTO RollBackTran         
            END                   
         END    

         -- 1 pallet 1 set of lottable
         SELECT TOP 1
            @cLottable01 = Lottable01, 
            @cLottable02 = Lottable02, 
            @cLottable03 = Lottable03, 
            @dLottable04 = Lottable04, 
            @cLottable06 = Lottable06, 
            @cLottable07 = Lottable07, 
            @cLottable08 = Lottable08, 
            @cLottable09 = Lottable09, 
            @cLottable10 = Lottable10,
            @cLottable11 = Lottable11, 
            @cLottable12 = Lottable12, 
            @dLottable13 = Lottable13, 
            @dLottable14 = Lottable14, 
            @dLottable15 = Lottable15
         FROM dbo.CCDetail WITH (NOLOCK)
         WHERE CCKey = @cCCKey
         AND   Storerkey = @cStorerKey
         AND   ID = CASE WHEN ISNULL( @cID, '') = '' THEN ID ELSE @cID END
         ORDER BY 1

         IF ISNULL(@nCountNo,'') = '1'    
         BEGIN    
            INSERT INTO CCDETAIL (  
               CCKey, CCDetailKey, CCSheetNo, TagNo, Storerkey, Sku, Lot, Loc, Id, SystemQty, Qty,   
               Lottable01, Lottable02, Lottable03, Lottable04, Lottable05, 
               Lottable06, Lottable07, Lottable08, Lottable09, Lottable10,
               Lottable11, Lottable12, Lottable13, Lottable14, Lottable15,
               FinalizeFlag, Status, Counted_Cnt1)    
            VALUES (  
               @cCCKey, @cCCDetailKey, @cCCSheetNo, '', @cStorerKey, @cSKU, '', @cLOC, @cID, 0, @nQty,   
               @cLottable01, @cLottable02, @cLottable03, @dLottable04, GETDATE(),    
               @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
               @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
               'N', '4', '1')    
            IF @@ERROR <> 0        
            BEGIN        
               SET @nErrNo = 234967       
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  --INS CCDtl Fail      
               GOTO RollBackTran        
            END       
         END               
         ELSE IF ISNULL(@nCountNo,'') = '2'    
         BEGIN       
            INSERT INTO CCDETAIL (  
               CCKey, CCDetailKey, CCSheetNo, TagNo, Storerkey, Sku, Lot, Loc, Id, SystemQty, Qty_Cnt2,   
               Lottable01, Lottable02, Lottable03, Lottable04, Lottable05, 
               Lottable06, Lottable07, Lottable08, Lottable09, Lottable10,
               Lottable11, Lottable12, Lottable13, Lottable14, Lottable15,
               FinalizeFlag, Status, Counted_Cnt2)    
            VALUES (  
               @cCCKey, @cCCDetailKey, @cCCSheetNo, '', @cStorerKey, @cSKU, '', @cLOC, @cID, 0, @nQty,   
               @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,    
               @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
               @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
               'N', '4', '1')    
            IF @@ERROR <> 0        
            BEGIN        
               SET @nErrNo = 234968        
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  --INS CCDtl Fail      
               GOTO RollBackTran        
            END               
         END     
         ELSE IF ISNULL(@nCountNo,'') = '3'    
         BEGIN       
            INSERT INTO CCDETAIL (  
               CCKey, CCDetailKey, CCSheetNo, TagNo, Storerkey, Sku, Lot, Loc, Id, SystemQty, Qty_Cnt3,   
               Lottable01, Lottable02, Lottable03, Lottable04, Lottable05, 
               Lottable06, Lottable07, Lottable08, Lottable09, Lottable10,
               Lottable11, Lottable12, Lottable13, Lottable14, Lottable15,
               FinalizeFlag, Status, Counted_Cnt3)    
            VALUES (@cCCKey, @cCCDetailKey, @cCCSheetNo, '', @cStorerKey, @cSKU, '', @cLOC, @cID, 0, @nQty,   
               @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,    
               @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
               @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
               'N', '4', '1')    
            IF @@ERROR <> 0        
            BEGIN        
               SET @nErrNo = 234968        
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  --INS CCDtl Fail      
               GOTO RollBackTran        
            END               
         END       
                         
      END     
   END

   GOTO QUIT  
     
  
   RollBackTran:  
      ROLLBACK TRAN rdt_732ExtendedCfm01  
  
   Quit:  
   WHILE @@TRANCOUNT>@nTranCount -- Commit until the level we started  
      COMMIT TRAN rdt_732ExtendedCfm01  
       
END -- End Procedure  
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON RDT.rdt_732ExtendedCfm01 TO NSQL
GO