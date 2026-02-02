

/***************************************************************************/
/* Store procedure: dbo.isp_PPA_WCS_ONBR                                   */
/* Copyright      : IDS                                                    */
/*                                                                         */
/* Purpose: PPA Reading for WCS                                            */
/*                                                                         */
/* Modifications log:                                                      */
/*                                                                         */
/* Date       Rev  Author  Purposes                                        */
/* 2025-08-29 1.0  elb02   Created                                         */
/***************************************************************************/

CREATE OR ALTER PROC  [dbo].[isp_PPA_WCS_ONBR] (
    @c_WaveKey            NVARCHAR(20), 
    @c_OrderKey           NVARCHAR(10),
	@c_OrderLineNumber    NVARCHAR(5),
    @c_DropId             NVARCHAR(20),
    @c_SKU                NVARCHAR(20),
    @n_CQty               INT, --IML will send Notes from pickdetail
    @n_Success            INT OUTPUT,
    @n_ErrNo              INT OUTPUT,
    @c_ErrMsg             NVARCHAR(250) OUTPUT
)
	
AS
BEGIN
    SET NOCOUNT ON
    SET QUOTED_IDENTIFIER OFF
    SET ANSI_NULLS OFF
    SET CONCAT_NULL_YIELDS_NULL OFF

    DECLARE @n_TranCount    INT = @@TRANCOUNT
    DECLARE @c_LoadKey      NVARCHAR (10)
	DECLARE @n_PQty         INT
	DECLARE @c_Status       NVARCHAR (1)
	DECLARE @c_UserName     NVARCHAR (3)
	DECLARE @d_AddDate      DATETIME
	DECLARE @n_NoofCheck    INT
	DECLARE @n_UOMQty       INT
	DECLARE @c_ArchiveCop   NVARCHAR (1)
	DECLARE @d_EditDate     DATETIME
	DECLARE @c_EditWho      NVARCHAR (3) 
	DECLARE @c_ID           NVARCHAR (18) --PICKDETAIL.ORDERLINENUMBER
    DECLARE @n_WaveCnt      INT
	DECLARE @n_OrdVldt      INT
	DECLARE @n_PPaVldt      INT
	DECLARE @c_StorerKey    NVARCHAR(10)
	DECLARE @c_Descr        NVARCHAR(60)
	
	-- Definitions
	SET @c_UserName  = 'WCS'
	SET @c_EditWho   = 'WCS'
	SET @c_Status    = '0'
	SET @n_UOMQty    = 1
	SET @n_NoofCheck = 1
	SET @d_AddDate   = GETDATE()
	SET @d_EditDate  = GETDATE()

    BEGIN         
		-- Check WaveKey/OrderKey
		SELECT @n_WaveCnt = COUNT(1) 
		  FROM DBO.WAVEDETAIL WITH (NOLOCK)
		 WHERE WAVEKEY = @c_WaveKey
		   AND OrderKey = @c_OrderKey
		
		IF ISNULL(@n_WaveCnt, 0) = 0
			BEGIN
			    SET @n_ErrNo = 50001
				SET @c_ErrMsg = 'Wave Not Found';
				THROW 50001, @c_ErrMsg, 2
			END
		
		-- Get StorerKey
		SELECT @c_StorerKey = StorerKey
		  FROM DBO.ORDERS WITH (NOLOCK)
		 WHERE OrderKey = @c_OrderKey

		-- Get PickQty
		SELECT @n_PQty = SUM(Qty)
		     , @c_Descr = SKU.DESCR
		  FROM DBO.PICKDETAIL WITH (NOLOCK)
		  JOIN DBO.SKU WITH (NOLOCK)
		    ON SKU.SKU = PICKDETAIL.SKU
		   AND PICKDETAIL.Storerkey = SKU.StorerKeY
		 WHERE PICKDETAIL.CaseID = @c_DropID
		   AND PICKDETAIL.OrderKey = @c_OrderKey
		   AND PICKDETAIL.OrderLineNumber = @c_OrderLineNumber
		   AND PICKDETAIL.SKU = @c_SKU
		   AND PICKDETAIL.Status = 5
		   GROUP BY SKU.DESCR

		IF ISNULL(@n_PQty,0) <> ISNULL(@n_CQty,0)
	    OR ISNULL(@n_PQty,0) = 0
	    OR ISNULL(@n_CQty,0) = 0
		BEGIN
			SET @n_ErrNo = 50002
			SET @c_ErrMsg = 'Qty Not Match';
			THROW 50002, @c_ErrMsg, 2
		END

		--Get PPA
		SELECT @n_PPaVldt = COUNT (*)
		  FROM RDT.RDTPPA WITH (NOLOCK)
         WHERE DROPID = @c_DropID
           AND OrderKey = @c_OrderKey
           AND ID = @c_OrderLineNumber
           AND SKU = @c_SKU
           AND StorerKey = @c_StorerKey
		   AND CQty = @n_CQty 
		   AND PQty = @n_PQty 


		IF ISNULL(@n_PPaVldt,0) > 0
		BEGIN
				SET @n_ErrNo  = 50003
				SET @c_ErrMsg = 'PPA Already Exist'; -- Id/Case Exists
				THROW 50003, @c_ErrMsg, 2
			END
    
	    ELSE
	    BEGIN                 
		INSERT INTO RDT.RDTPPA(StorerKey
		                     , Sku
							 , Descr
							 , PQty
							 , CQty
							 , Status
							 , UserName
							 , AddDate
							 , NoofCheck
							 , UOMQty
							 , ArchiveCop
							 , OrderKey
							 , DropID
							 , EditDate
							 , EditWho
							 , ID
		)

		                VALUES(@c_StorerKey
						     , @c_SKU
						     , @c_Descr
							 , @n_PQty
							 , @n_CQty
							 , @c_Status
							 , @c_UserName
							 , @d_AddDate
							 , @n_NoofCheck
							 , @n_UOMQty
							 , NULL
							 , @c_OrderKey	
							 , @c_DropID
							 , @d_EditDate
							 , @c_EditWho
							 , @c_OrderLineNumber
		)

		IF @@ERROR <> 0     
            BEGIN
			    SET @n_ErrNo  = 50004
                SET @c_ErrMsg = 'PPA Insert Fail';  -- Ins Fail  
				THROW 50004, @c_ErrMsg, 2
            END   
		
		ELSE
		SET @n_Success = 1
		END
    END  

END

GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXEC ON dbo.isp_PPA_WCS_ONBR TO NSQL
GO
