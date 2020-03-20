IF EXISTS (SELECT Name FROM dbo.sysobjects WHERE Name = 'isp_UCC_Carton_Label_68' AND Type = 'P')
   DROP PROC isp_UCC_Carton_Label_68
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO 
/************************************************************************/
/* Store Procedure:  isp_UCC_Carton_Label_68                            */
/* Creation Date:21-NOV-2017                                            */
/* Copyright: IDS                                                       */
/* Written by: WLCHOOI                                                  */
/*                                                                      */
/* Purpose:  WMS-3424 -KR - NIKE - Carton Packing Label                 */
/*                                                                      */
/* Input Parameters: Storerkey, PickSlipNo, CartonNoStart, CartonNoEnd  */
/*                                                                      */
/* Output Parameters:                                                   */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Called By:  r_dw_ucc_carton_label_68                                 */
/*                                                                      */
/* PVCS Version: 1.2                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author   Ver  Purposes                                  */
/* 28-Feb-2017  CSCHONG  1.0  WMS-4163 revised field logic (CS01)       */
/* 22-MAR-2018  CSCHONG  1.1  WMS-4353 Fix qty issue (CS02)             */
/* 21-MAY-2018  WAN01    1.2  WMS-5095 - CR Nike Korea ECOM Invoice Report*/
/************************************************************************/

CREATE PROC [dbo].[isp_UCC_Carton_Label_68] (
	       -- @c_Storerkey      NVARCHAR(20)  
           @c_PickSlipNo     NVARCHAR(20)
        ,  @c_StartCartonNo  NVARCHAR(20) = '1'
        ,  @c_EndCartonNo    NVARCHAR(20) = '9999'
)
AS
BEGIN

   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF


   DECLARE @c_ExternOrderkey  NVARCHAR(150)
         , @c_Orderkey        NVARCHAR(20)
		   , @c_AltSku		      NVARCHAR(50)
		   , @c_ODNotes1		   NVARCHAR(1000)
		   , @c_ODNotes2		   NVARCHAR(1000)
		   , @n_ODUnitPrice	   FLOAT
         , @n_PDqty           INT
         , @c_GetPickslipno   NVARCHAR(20)

		 , @n_CntSize         INT
		 , @n_Page            INT
		 , @c_ordkey          NVARCHAR(20)
		 , @n_PrnQty          INT
		 , @n_MaxId           INT
		 , @n_MaxRec          INT
		 , @n_getPageno       INT
		 , @n_MaxLineno       INT
		 , @n_CurrentRec      INT
	   
		 SET @c_ExternOrderkey  = ''
		 SET @c_Orderkey        = ''
		 SET @c_AltSku          = ''
		 SET @c_ODNotes1		   = ''
		 SET @c_ODNotes2		   = ''
		 SET @n_ODUnitPrice     = 0.00
		 SET @n_PDqty           = 0
		 SET @c_GetPickslipno   = ''

		 SET @n_CntSize         = 1
		 SET @n_Page            = 1
		 SET @n_PrnQty          = 1
		 SET @n_PrnQty          = 1
		 SET @n_MaxLineno       = 17   
		
		CREATE TABLE #TMP_LCartonLABEL68 (
		         rowid           int NOT NULL identity(1,1) PRIMARY KEY,
				 C_company		    NVARCHAR(100) NULL,
				 Pickslipno        NVARCHAR(20) NULL,
				 OrdExtOrdKey      NVARCHAR(150) NULL,
				 Orderkey          NVARCHAR(20) NULL,
				 AltSku			    NVARCHAR(20) NULL,
				 ODNotes1		    NVARCHAR(1000) NULL,
				 ODNotes2		    NVARCHAR(1000) NULL,
				 ODUnitPrice	    FLOAT NULL,
				 PDQty             INT
		                                )
         SET @c_Orderkey = ''                                                                            --(Wan01)
		   IF EXISTS (SELECT 1 FROM ORDERS WITH (NOLOCK)
		              WHERE ORDERKEY = @c_PickSlipNo)
		   BEGIN
		   	SET @c_Orderkey=@c_PickSlipNo
		   	
		   	SELECT @c_GetPickslipno = MIN(PH.Pickslipno) 
    	      FROM PACKHEADER PH WITH (NOLOCK)
    	      WHERE PH.Orderkey = @c_Orderkey
    	      SET @c_StartCartonNo = '1'
    	      SET @c_EndCartonNo   ='9999'
    	      
		   END 
		   ELSE
		   BEGIN 	          
				SELECT TOP 1 @c_Orderkey = PAH.OrderKey
				FROM PICKHEADER PAH WITH (NOLOCK)                                                            --(Wan01)
				--JOIN PACKDETAIL PADET WITH (NOLOCK) ON PAH.Pickslipno = PADET.Pickslipno                   --(Wan01)
				WHERE PAH.PickHeaderkey = @c_PickSlipNo                                                      --(Wan01)   
				--AND PADET.CartonNo between CONVERT(INT,@c_StartCartonNo) AND CONVERT(INT,@c_EndCartonNo)   --(Wan01)
				
				SET @c_GetPickslipno=@c_PickSlipNo
				
		   END
		   
		    SET @c_ExternOrderkey = ''
          IF @c_Orderkey = ''
          BEGIN
          	
          	SELECT @c_Orderkey = MIN(OH.Orderkey)
          	FROM PACKHEADER PAH WITH (NOLOCK)
			   --JOIN PACKDETAIL PADET WITH (NOLOCK) ON PAH.Pickslipno = PADET.Pickslipno                   --(Wan01)
          	JOIN ORDERS OH WITH (NOLOCK) ON OH.loadkey = PAH.LoadKey 
          	WHERE PAH.Pickslipno = @c_PickSlipNo
				-- AND PADET.CartonNo between CONVERT(INT,@c_StartCartonNo) AND CONVERT(INT,@c_EndCartonNo)  --(Wan01)
				 
          END
          ELSE
          BEGIN
          	SELECT @c_ExternOrderkey = OH.M_company--OH.ExternOrderKey   --CS01
          	FROM ORDERS OH WITH (NOLOCK)
          	WHERE Orderkey = @c_Orderkey
          END	
          
		INSERT INTO #TMP_LCartonLABEL68 (
			C_company
			,Pickslipno
			,OrdExtOrdKey
			,Orderkey
			,AltSku
			,ODNotes1
			,ODNotes2
			,ODUnitPrice
			,PDQTY
			)

		SELECT DISTINCT CONCAT(SUBSTRING(Orders.c_company,1,1),'*',SUBSTRING(Orders.c_company,3,LEN(Orders.c_company)))
			,  @c_GetPickslipno
			,  @c_ExternOrderkey
			,  @c_Orderkey
			,  SKU.ALTSKU
			,  OrderDetail.Notes
			,  OrderDetail.Notes2
			,  (OrderDetail.UnitPrice * OrderDetail.QtyPicked)
			--,  sum(ISNULL(PickDetail.Qty,0))                      --CS01     --CS02
			--,PickDetail.Qty                                         --CS02
         ,  OrderDetail.QtyPicked                                 --(Wan01)                 
		FROM ORDERDETAIL WITH (NOLOCK)
		INNER JOIN ORDERS WITH (NOLOCK) ON (ORDERS.ORDERKEY = ORDERDETAIL.ORDERKEY)
		INNER JOIN SKU WITH (NOLOCK) ON (ORDERDETAIL.SKU = SKU.SKU)
		INNER JOIN PICKDETAIL WITH (NOLOCK) ON (ORDERS.ORDERKEY = PICKDETAIL.ORDERKEY) AND (PICKDETAIL.SKU = SKU.SKU)
		--INNER JOIN PACKDETAIL WITH (NOLOCK) ON ORDERDETAIL.SKU = PACKDETAIL.SKU                       --(WAN01)
		WHERE ORDERS.ORDERKEY = @c_orderkey --AND PACKDETAIL.PICKSLIPNO = @c_GetPickslipno              --(WAN01)
		-- AND PACKDETAIL.CartonNo between CONVERT(INT,@c_StartCartonNo) AND CONVERT(INT,@c_EndCartonNo)--(WAN01)
		GROUP BY
			Orders.c_company
			,SKU.ALTSKU
			,OrderDetail.Notes
			,OrderDetail.Notes2
			,OrderDetail.UnitPrice
			,OrderDetail.QtyPicked
			--,PickDetail.Qty        --CS01         --CS02           --(Wan01)


		SELECT DISTINCT c_company
		,Pickslipno
		,OrdExtOrdKey
		,Orderkey
		,AltSku
		,ODNotes1
		,ODNotes2
		,ODUnitPrice
		,sum(PDQty) AS PQTY                         --CS02
		FROM 	#TMP_LCartonLABEL68
		GROUP BY c_company
		,Pickslipno
		,OrdExtOrdKey
		,Orderkey
		,AltSku
		,ODNotes1
		,ODNotes2
		,ODUnitPrice
		ORDER BY ALTSKU


END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF
GO
       
GRANT EXECUTE ON isp_UCC_Carton_Label_68 TO NSQL
GO   
