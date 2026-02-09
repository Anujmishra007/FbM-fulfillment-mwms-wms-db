SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1641ExtUpdSP17                                  */
/* Copyright      : IDS                                                 */
/*                                                                      */
/* Called from: rdtfnc_Pallet_Build                                     */
/*                                                                      */
/* Purpose: Build pallet & palletdetail                                 */
/*                                                                      */
/* Modifications log:                                                   */
/* Date        Rev  Author   Purposes                                   */
/* 2025-12-12  1.0  PSJ036  UWP-48076 Created                           */
/************************************************************************/
CREATE OR ALTER PROC [RDT].[rdt_1641ExtUpdSP17] (
	@nMobile 		INT
	,@nFunc 		INT
	,@cLangCode 	NVARCHAR(3)
	,@cUserName 	NVARCHAR(15)
	,@cFacility 	NVARCHAR(5)
	,@cStorerKey 	NVARCHAR(15)
	,@cDropID 		NVARCHAR(20)
	,@cUCCNo 		NVARCHAR(20)
	,@nErrNo 		INT OUTPUT
	,@cErrMsg 		NVARCHAR(20) OUTPUT -- screen limitation, 20 char max    
	)
AS
BEGIN
	SET NOCOUNT ON
	SET ANSI_NULLS OFF
	SET QUOTED_IDENTIFIER OFF
	SET CONCAT_NULL_YIELDS_NULL OFF

	DECLARE @nStep 			INT
		,@nInputKey 		INT
		,@nTranCount 		INT
		,@nPD_Qty 			INT
		,@cSKU 				NVARCHAR(20)
		,@cOrderKey 		NVARCHAR(10)
		,@cCurOrderKey 		NVARCHAR(10)
		,@cPickSlipNo 		NVARCHAR(10)
		,@cPalletLineNumber NVARCHAR(5)
		,@cCaseID 			NVARCHAR(20)
		,@nQty 				INT
		,@cOption 			NVARCHAR(1) = ''
		,@cCountry 			NVARCHAR(20)
		,@cPlatform 		NVARCHAR(20)
		,@cDefaultLoc 		NVARCHAR(20)
		,@cUserDefine03 	NVARCHAR(20)
		,@cLoadkey 			NVARCHAR(10)
		,@cShipperKey 		NVARCHAR(20)
		,@cLoc 				NVARCHAR(20)
		,@cFromLoc 			NVARCHAR(20)
		,@cFromID 			NVARCHAR(20)

	SELECT @nStep     = Step
		  ,@nInputKey = InputKey
	FROM   rdt.RDTMobRec WITH (NOLOCK)
	WHERE  Mobile = @nMobile

	SET @nTranCount = @@TRANCOUNT

	BEGIN TRAN

	SAVE TRAN rdt_1641ExtUpdSP17

	IF @nStep = 3
	BEGIN
		IF @nInputKey = 1
		BEGIN
			IF EXISTS (SELECT 1 FROM dbo.PalletDetail WITH (NOLOCK)
					   WHERE StorerKey = @cStorerKey
					   AND   CaseId    = @cUCCNo)
			BEGIN
				SET @nErrNo = 258251
				SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --Carton_Exist
				GOTO RollBackTran
			END

			-- Check if pallet id exists before  
			IF NOT EXISTS (SELECT 1 FROM dbo.Pallet WITH (NOLOCK)
						   WHERE PalletKey = @cDropID)
			BEGIN
				-- Insert Pallet info  
				BEGIN TRY
					INSERT INTO dbo.Pallet (PalletKey,StorerKey)
					VALUES (@cDropID,@cStorerKey)
				END TRY

				BEGIN CATCH
					SET @nErrNo = 258252
					SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --InsPLTFail  
					GOTO RollBackTran
				END CATCH
			END

			SET @cDefaultLoc = rdt.RDTGetConfig(@nFunc, 'DefaultLoc', @cStorerKey)

			-- Insert PalletDetail   
			DECLARE CUR_PalletDetail CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
			SELECT PickSlipNo
				  ,SKU
			      ,ISNULL(SUM(Qty), 0)
			FROM  dbo.PackDetail WITH (NOLOCK)
			WHERE StorerKey = @cStorerKey
				AND LabelNo = @cUCCNo
			GROUP BY PickSlipNo ,SKU

			OPEN CUR_PalletDetail

			FETCH NEXT
			FROM CUR_PalletDetail
			INTO @cPickSlipNo
				,@cSKU
				,@nPD_Qty

			WHILE @@FETCH_STATUS <> - 1
			BEGIN
				SELECT @cOrderKey = OrderKey
				FROM  dbo.PackHeader WITH (NOLOCK)
				WHERE PickSlipNo = @cPickSlipNo

				SELECT @cCountry    = O.C_Country
					  ,@cPlatform   = OI.Platform
					  ,@cShipperKey = O.ShipperKey
				FROM  dbo.ORDERS O WITH (NOLOCK)
				JOIN  dbo.OrderInfo OI WITH (NOLOCK) ON O.orderkey = OI.OrderKey
				WHERE O.OrderKey = @cOrderKey

				SELECT @cLoadkey = O.LoadKey
				FROM   dbo.ORDERS O WITH (NOLOCK)
				WHERE  O.OrderKey = @cOrderKey

				BEGIN TRY
					INSERT INTO dbo.PalletDetail (
						PalletKey
						,PalletLineNumber
						,CaseId
						,StorerKey
						,Sku
						,Qty
						,UserDefine01
						,UserDefine02
						,UserDefine03
						,Loc
						)
					VALUES (
						@cDropID
						,0
						,@cUCCNo
						,@cStorerKey
						,@cSKU
						,@nPD_Qty
						,@cCountry + @cPlatform + @cShipperKey
						,@cOrderKey
						,@cLoadkey
						,@cDefaultLoc
						)

					UPDATE dbo.ORDERS
					WITH  (ROWLOCK)
					SET   [DeliveryNote] = @cDropID
					WHERE OrderKey = @cOrderKey
					  AND StorerKey = @cStorerKey

					UPDATE dbo.Dropid
					WITH  (ROWLOCK)
					SET   [LoadKey] = @cLoadkey
					WHERE DropID = @cDropID
				END TRY

				BEGIN CATCH
					SET @nErrNo = 258253
					SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --InsPLTDetFail  
					IF CURSOR_STATUS('local', 'CUR_PalletDetail') >= - 1
					BEGIN
						CLOSE CUR_PalletDetail;
						DEALLOCATE CUR_PalletDetail;
					END
					GOTO RollBackTran
				END CATCH

				FETCH NEXT
				FROM CUR_PalletDetail
				INTO @cPickSlipNo
					,@cSKU
					,@nPD_Qty
			END

			CLOSE CUR_PalletDetail
			DEALLOCATE CUR_PalletDetail
		END
	END

	IF @nStep = 4
	BEGIN
		IF @nInputKey = 1
		BEGIN
			SELECT @cOption = I_Field01
			FROM   rdt.RDTMobRec WITH (NOLOCK)
			WHERE  Mobile = @nMobile

			IF @cOption = '1'
			BEGIN
				IF NOT EXISTS (SELECT 1 FROM dbo.Pallet WITH (NOLOCK)
						       WHERE StorerKey = @cStorerKey
						       AND   PalletKey   = @cDropID
						       AND  [Status] < '9')
				BEGIN
					SET @nErrNo = 258254
					SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --PLTKeyNotFound  
					GOTO RollBackTran
				END

				IF NOT EXISTS (SELECT 1	FROM dbo.PALLETDETAIL WITH (NOLOCK)
							   WHERE StorerKey = @cStorerKey
							   AND   PalletKey = @cDropID
							   AND  [Status] < '9')
				BEGIN
					SET @nErrNo = 258255
					SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --No Ctn Scanned  
					GOTO RollBackTran
				END

				DECLARE @cPickdetailkey		NVARCHAR(20)
					   ,@clot 				NVARCHAR(20)
					   ,@nPalletQty 		INT
					   ,@nQtyBalance 		INT
					   ,@nQtyToMove 		INT

				SET @cDefaultLoc = rdt.RDTGetConfig(@nFunc, 'DefaultLoc', @cStorerKey)

				DECLARE CUR_Pallet CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
				SELECT userdefine02
					  ,Packdet.qty
				FROM  dbo.PalletDetail PD WITH (NOLOCK)
				INNER JOIN dbo.PackDetail PackDet WITH (NOLOCK) ON PackDet.StorerKey = PD.StorerKey
					AND PackDet.LabelNo = PD.CaseID
				WHERE PD.StorerKey = @cStorerKey
					AND PalletKey = @cDropID
					AND [Status] < '9'

				OPEN CUR_Pallet

				FETCH NEXT
				FROM CUR_Pallet
				INTO @cCurOrderKey
					,@nPalletQty

				WHILE @@FETCH_STATUS <> - 1
				BEGIN
					SET @cFromID = ''
					SET @nPD_Qty = 0
					SET @nQtyBalance = @nPalletQty

					DECLARE CUR_Pickdetail CURSOR LOCAL READ_ONLY FAST_FORWARD
					FOR
					SELECT pkd.PickDetailKey
						  ,pkd.qty
						  ,pkd.sku
						  ,pkd.Loc
						  ,pkd.ID
						  ,pkd.lot
					FROM dbo.PICKDETAIL PKD WITH (NOLOCK)
					WHERE  PKD.StorerKey = @cStorerKey
						AND PKD.[Status] = '5'
						AND PKD.orderkey = @cCurOrderKey
					ORDER BY pickdetailkey

					OPEN CUR_Pickdetail

					FETCH NEXT
					FROM CUR_Pickdetail
					INTO @cPickdetailkey
						,@nPD_Qty
						,@csku
						,@cFromLoc
						,@cFromID
						,@clot

					WHILE @@FETCH_STATUS <> - 1
					BEGIN
						IF @nQtyBalance > @nPD_Qty
							SET @nQtyToMove = @nPD_Qty
						ELSE
							SET @nQtyToMove = @nQtyBalance

						EXECUTE rdt.rdt_Move @nMobile 	= @nMobile
							,@cLangCode					= @cLangCode
							,@nErrNo 					= @nErrNo OUTPUT
							,@cErrMsg 					= @cErrMsg OUTPUT -- screen limitation, 20 NVARCHAR max        
							,@cSourceType 				= 'rdt_1641ExtUpdSP17'
							,@cStorerKey 				= @cStorerKey
							,@cFacility 				= @cFacility
							,@cFromLOC				    = @cFromLoc
							,@cToLOC 					= @cDefaultLoc
							,@cFromID 					= @cFromID -- NULL means not changing ID. Blank consider a valid ID        
							,@cToID 					= @cDropID -- NULL means not changing ID. Blank consider a valid ID        
							,@cSKU 						= @cSKU
							,@cFROMLot 					= @clot
							,@nFunc 					= @nFunc
							,@nQty						= @nQtyToMove
							,@nQTYPick 					= @nQtyToMove
							,@cOrderKey 				= @cCurOrderKey

						IF @nErrNo <> 0
						BEGIN
							IF CURSOR_STATUS('local', 'CUR_PalletDetail') >= - 1
							BEGIN
								CLOSE CUR_PalletDetail;
								DEALLOCATE CUR_PalletDetail;
							END

							IF CURSOR_STATUS('local', 'CUR_Pallet') >= - 1
							BEGIN
								CLOSE CUR_Pallet;
								DEALLOCATE CUR_Pallet;
							END
							GOTO RollBackTran
						END

						SET @nQtyBalance = @nQtyBalance - @nPD_Qty

						IF @nQtyBalance <= 0
							BREAK

						FETCH NEXT
						FROM CUR_Pickdetail
						INTO @cPickdetailkey
							,@nPD_Qty
							,@csku
							,@cFromLoc
							,@cFromID
							,@clot
					END

					CLOSE CUR_Pickdetail
					DEALLOCATE CUR_Pickdetail

					FETCH NEXT
					FROM CUR_Pallet
					INTO @cCurOrderKey
						,@nPalletQty
				END

				CLOSE CUR_Pallet
				DEALLOCATE CUR_Pallet

				BEGIN TRY
					UPDATE dbo.PALLETDETAIL
					WITH (ROWLOCK)
					SET [Status] = '9'
					WHERE StorerKey = @cStorerKey
						AND PalletKey = @cDropID
						AND [Status] < '9'
				END TRY
				BEGIN CATCH
					SET @nErrNo = 258256
					SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --Upd PLTDet Err  
					GOTO RollBackTran
				END CATCH

				BEGIN TRY
					UPDATE dbo.PALLET
					WITH (ROWLOCK)
					SET [Status] = '9'
					WHERE StorerKey = @cStorerKey
						AND PalletKey = @cDropID
						AND [Status] < '9'
				END TRY
				BEGIN CATCH
					SET @nErrNo = 258257
					SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --Close Plt Fail  
					GOTO RollBackTran
				END CATCH

				BEGIN TRY
					UPDATE dbo.DROPID
					WITH (ROWLOCK)
					SET [Status] = '5'
						,[LabelPrinted] = 'Y'
					WHERE DropID = @cDropID
				END TRY
				BEGIN CATCH
					SET @nErrNo = 258258
					SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --Upd DROPIDFail
					GOTO RollBackTran
				END CATCH

				IF EXISTS (SELECT 1	FROM rdt.RDTReport WITH (NOLOCK)
						   WHERE StorerKey = @cStorerKey
						   AND ReportType = 'LPALLET')
				BEGIN
					DECLARE @tOutBoundLis AS VariableTable
					DELETE	FROM @tOutBoundLis
					INSERT INTO @tOutBoundLis (
						Variable
						,Value
						)
					VALUES ('@cStorerKey'
						    ,@cStorerKey)
						  ,('@cPalletKey'
						    ,@cDropID)

					-- Get printer
					DECLARE @cLabelPrinter NVARCHAR(10)
					DECLARE @cPaperPrinter NVARCHAR(10)

					SELECT @cLabelPrinter = Printer
						  ,@cPaperPrinter = Printer_Paper
					FROM   rdt.rdtMobRec WITH (NOLOCK)
					WHERE  Mobile = @nMobile

					-- Print label    
					EXEC RDT.rdt_Print @nMobile
						,@nFunc
						,@cLangCode
						,@nStep
						,@nInputKey
						,@cFacility
						,@cStorerKey
						,@cLabelPrinter
						,@cPaperPrinter
						,'LPALLET'     -- Report type    
						,@tOutBoundLis -- Report params    
						,'rdt_1641ExtUpdSPON'
						,@nErrNo OUTPUT
						,@cErrMsg OUTPUT

					IF @nErrNo <> 0
						GOTO RollBackTran
				END
			END
		END
	END

	IF @nStep = 7 --(yeekung01)
	BEGIN
		IF @nInputKey = 1
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM dbo.PALLETDETAIL PD WITH (NOLOCK)
						   JOIN dbo.MBOLDETAIL MD WITH (NOLOCK) ON PD.UserDefine02 = MD.OrderKey
						   JOIN dbo.PICKDETAIL PKD WITH (NOLOCK) ON MD.ORDERKEY = PKD.ORDERKEY
						   WHERE PD.StorerKey = @cStorerKey
						   	   AND PD.PalletKey = @cDropID
						   	   AND PKD.STATUS = 9
						   	   AND PD.STATUS = 9)
			BEGIN
				BEGIN TRY
					UPDATE dbo.PALLETDETAIL
					WITH (ROWLOCK)
					SET [Status] = '0'
					WHERE StorerKey = @cStorerKey
						AND PalletKey = @cDropID
						AND [Status] = '9'
				END TRY
				BEGIN CATCH
					SET @nErrNo = 258259
					SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --Upd pltdt fail  
					GOTO RollBackTran
				END CATCH

				BEGIN TRY
					UPDATE dbo.PALLET
					WITH (ROWLOCK)
					SET [Status] = '0'
						,[TrafficCop] = NULL
					WHERE StorerKey = @cStorerKey
						AND PalletKey = @cDropID
						AND [Status] = '9'
				END TRY
				BEGIN CATCH
					SET @nErrNo = 258260
					SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --Upd Plt Fail     
					GOTO RollBackTran
				END CATCH
			END
			ELSE
			BEGIN
				SET @nErrNo = 258261
				SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --PltShipped  

				GOTO RollBackTran
			END
		END
	END

	GOTO Quit

	RollBackTran:

	ROLLBACK TRAN rdt_1641ExtUpdSP17

	Quit:

	WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started  
		COMMIT TRAN rdt_1641ExtUpdSP17
END
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_1641ExtUpdSP17] TO [NSQL]
GO


