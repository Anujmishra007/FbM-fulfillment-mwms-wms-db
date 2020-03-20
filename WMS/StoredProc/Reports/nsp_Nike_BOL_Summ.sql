IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[nsp_Nike_BOL_Summ]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[nsp_Nike_BOL_Summ]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Store Procedure:  nsp_Nike_BOL_Summ                            		*/
/* Creation Date:                                     						*/
/* Copyright: IDS                                                       */
/* Written by:                                                 			*/
/*                                                                      */
/* Purpose:  BOL Summary Report                                         */
/*                                                                      */
/* Usage:  Used for report dw = r_dw_bol_summ_nikecn                    */
/*                                                                      */
/* Called By: Exceed                                      					*/
/*                                                                      */
/* PVCS Version: 1.10                                                   */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author     Purposes                                     */
/* 18-Jun-2003  Vicky      - (SOS#11842)                                */
/*                         Use left outer join so that those orders     */
/*                         which is not go through pack module will be  */
/*                         able to retrieve.                            */
/* 06-NOV-2003  Shong      - Remove duplicate lines for 1 load.         */
/* 19-Feb-2004  WANYT      - (SOS#20100)                                */
/*                         Additional filter to retrieve record within  */
/*                         parameters facility start & fcility end.     */
/* 03-Dec-2004  June       - (SOS#30046) - Add QtyPicked.               */
/* 03-Aug-2005  YokeBeen   - (SOS#38255) - (YokeBeen01).                */
/*                         - Enlarged the size from NVARCHAR(45)-char(100). */
/*                         - Changed to extract data for -              */
/*                         1. ShipToCity - from C_Address4 to C_City    */ 
/*                         2. ShipToAddress - from C_Address1 to        */
/*                                            C_Address3 + C_Address4 + */
/*                                            C_Address2                */ 
/* 29-Nov-2005	 MaryVong	SOS42901 NIKECN - Add PickSlipNo            */
/* 06-Oct-2016	 TLTING     SET OPTION                                  */
/*                                                                      */
/* 26-Feb-2018   CSCHONG    WMS-3990 add new field (CSO1)               */
/************************************************************************/

CREATE PROC [dbo].[nsp_Nike_BOL_Summ] (
		@c_loadkey_start NVARCHAR(10),
		@c_loadkey_end NVARCHAR(10),
		@dt_shipdate_start datetime,
		@dt_shipdate_end datetime,
		@c_facility_start NVARCHAR(5),  
		@c_facility_end NVARCHAR(5)  
) 
AS
BEGIN  
   SET NOCOUNT ON 
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF 
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   
   
   /*CS01 Start*/
   
   DECLARE @c_loadkey NVARCHAR(20)
          ,@c_Refno   NVARCHAR(20)
   
   /*CS01 End*/
   
	-- Added By WANYT on 19 Feb 2004 - START
	-- Create table #tempbol and set some field to allow null value
   CREATE TABLE #TEMPBOL (
			Loadkey         NVARCHAR(10),
			EditDate        datetime,
			ShipQty         int,
			FreightCost     NVARCHAR(30) NULL,
			Carrierkey      NVARCHAR(15) NULL,
			ConsigneeKey    NVARCHAR(15) NULL,   
			C_Address       NVARCHAR(100) NULL,   		-- (YokeBeen01) 
			C_City          NVARCHAR(45)NULL,   				-- (YokeBeen01)
			PodReceivedDate datetime NULL,
			PODDate01       datetime NULL,
			PODDef07        NVARCHAR(30) NULL,
			Adddate         datetime,
			PickSlipNo      NVARCHAR(10) NULL	-- SOS42901  --CS01
			,DC             NVARCHAR(50) )                   --CS01
	-- Added By WANYT on 19 Feb @004 - END

   -- Modified By SHONG on 06-NOV-2003 
   -- Modified BY WANYT on 19 Feb 2004 
	INSERT INTO #tempbol   
	SELECT LOADPLAN.Loadkey,
          MBOL.Editdate,
          --ShipQty = SUM(ORDERDETAIL.ShippedQty+ORDERDETAIL.QtyPicked), -- SOS30046, add QtyPicked  --CS01
          shipQty = SUM(PD.qty),                                 --CS01
          FreightCost = SPACE(30),
          CASE WHEN (dbo.fnc_RTrim(LOADPLAN.Carrierkey) IS NULL OR 
                     dbo.fnc_RTrim(LOADPLAN.Carrierkey) = '' ) AND
                     ORDERS.Facility IN ('NSH01', 'NSH03', 'NGZ01', 'NGZ03') THEN 'DUMMY'
               ELSE LOADPLAN.Carrierkey
          END as Carrierkey,
          SPACE(15) as ConsigneeKey,   
          SPACE(100) as C_Address,   		-- (YokeBeen01) 
          SPACE(45) as C_City,   			-- (YokeBeen01) 
          GetDate() as PodReceivedDate,
          GetDate() PODDate01,
          SPACE(30) as PODDef07,
          LOADPLAN.Adddate,
			 PICKHEADER.PickHeaderKey	-- SOS42901
			 ,case when isnull(C.Code,'') <> '' THEN C.Code ELSE L.PickZone END AS DC    --CS01
--    INTO #TEMPBOL               
    FROM LOADPLAN (NOLOCK)
         JOIN LOADPLANDETAIL Loadplandetail (NOLOCK) ON ( LOADPLAN.Loadkey = LOADPLANDETAIL.Loadkey )
         JOIN ORDERS Orders (NOLOCK) ON (ORDERS.Loadkey = LOADPLAN.Loadkey )
         JOIN ORDERDETAIL orderdetail (NOLOCK) on (ORDERDETAIL.Orderkey = ORDERS.Orderkey 
                                                   and ORDERDETAIL.Storerkey = ORDERS.Storerkey
                                                   and Orderdetail.Orderkey = LOADPLANDETAIL.Orderkey)   
         JOIN POD pod (NOLOCK) ON (LOADPLAN.Loadkey = POD.Loadkey 
                                and POD.Orderkey = Orders.Orderkey ) 
         JOIN MBOL MBOL (NOLOCK) ON (MBOL.Mbolkey = ORDERS.Mbolkey )
			-- SOS42901
			JOIN PICKHEADER (NOLOCK) ON (PICKHEADER.ExternOrderKey = LOADPLAN.LoadKey)
			--CS01 start
			LEFT JOIN PICKDETAIL PD (NOLOCK) ON PD.orderkey = ORDERS.OrderKey
			LEFT JOIN LOC L WITH (NOLOCK) ON L.loc=pd.Loc
			LEFT JOIN CODELKUP C WITH (NOLOCK) ON C.listname = 'ALLSorting' AND
			C.Storerkey=ORDERS.StorerKey AND C.code2=L.PickZone
			--CS01 End
   WHERE ( ORDERS.Status = '9' ) and
         ( LOADPLAN.Loadkey BETWEEN @c_loadkey_start AND @c_loadkey_end ) and
         ( MBOL.EditDate BETWEEN @dt_shipdate_start AND @dt_shipdate_end ) and
         ( LOADPLAN.Facility BETWEEN @c_facility_start AND @c_facility_end )
   GROUP BY LOADPLAN.Loadkey,
         MBOL.Editdate,
         CASE WHEN (dbo.fnc_RTrim(LOADPLAN.Carrierkey) IS NULL OR 
                     dbo.fnc_RTrim(LOADPLAN.Carrierkey) = '' ) AND
                     ORDERS.Facility IN ('NSH01', 'NSH03', 'NGZ01', 'NGZ03') THEN 'DUMMY'
               ELSE LOADPLAN.Carrierkey
         END,
         LOADPLAN.Adddate,
			PICKHEADER.PickHeaderKey	-- SOS42901   
			,case when isnull(C.Code,'') <> '' THEN C.Code ELSE L.PickZone END     --CS01

   -- Added By SHONG on 06-NOV-2003 (begin)
   UPDATE #TEMPBOL
      SET FreightCost = POD.PODDef06,
          PODDef07    = POD.PODDef07,
          PodReceivedDate = POD.PodReceivedDate,
          PODDate01 = POD.actualdeliverydate
   FROM POD (NOLOCK)
   WHERE #TEMPBOL.LoadKey = POD.LoadKey

   UPDATE #TEMPBOL
      SET ConsigneeKey = ORDERS.ConsigneeKey,
          -- (YokeBeen01) - Start
          C_City = ORDERS.C_City,   
          C_Address = dbo.fnc_LTrim(dbo.fnc_RTrim(ORDERS.C_Address3)) + ' ' + dbo.fnc_LTrim(dbo.fnc_RTrim(ORDERS.C_Address4)) + ' ' + 
                   dbo.fnc_LTrim(dbo.fnc_RTrim(ORDERS.C_Address2))  
          -- (YokeBeen01) - End
   FROM  ORDERS (NOLOCK)
   WHERE #TEMPBOL.LoadKey = ORDERS.LoadKey
   -- Added By SHONG on 06-NOV-2003 (end)
   
   /*CS01 Start*/
     CREATE TABLE #TEMPBOLQty (
			Loadkey         NVARCHAR(10) NULL,
			PickSlipNo      NVARCHAR(10) NULL,
			DC              NVARCHAR(20) NULL,
			Qty             INT)
			
			INSERT INTO #TEMPBOLQty
			(
				Loadkey,
				PickSlipNo,
				DC,
				Qty
			)
			SELECT ord.LoadKey,PICKHEADER.PickHeaderKey,c.Code,SUM(qty) QTY 
			FROM  dbo.PICKDETAIL (nolock) pd 
			JOIN orders ord (NOLOCK) ON ord.OrderKey=pd.OrderKey
			JOIN LOADPLAN LP (NOLOCK) ON LP.LoadKey=ORD.LoadKey
			 JOIN MBOL MBOL (NOLOCK) ON (MBOL.Mbolkey = ord.Mbolkey )
			JOIN loc (nolock) l ON pd.Loc=l.Loc
			JOIN dbo.CODELKUP (nolock) c ON c.LISTNAME='allsorting' 
			AND l.PickZone=c.code2 AND pd.Storerkey=c.Storerkey
			JOIN PICKHEADER (NOLOCK) ON (PICKHEADER.ExternOrderKey = LP.LoadKey)
			WHERE pd.OrderKey IN (
              SELECT OrderKey from dbo.ORDERDETAIL (NOLOCK) WHERE LoadKey BETWEEN @c_loadkey_start AND @c_loadkey_end ) 	
			AND ( ORD.Status = '9' ) and
         ( LP.Loadkey BETWEEN @c_loadkey_start AND @c_loadkey_end ) and
         ( MBOL.EditDate BETWEEN @dt_shipdate_start AND @dt_shipdate_end ) and
         ( LP.Facility BETWEEN @c_facility_start AND @c_facility_end )	
			 GROUP BY c.code,ord.LoadKey ,PICKHEADER.PickHeaderKey
			
			UPDATE #TEMPBOL
			SET ShipQty = TBQ.Qty
			FROM #TEMPBOLQty TBQ
			WHERE #TEMPBOL.loadkey = TBQ.Loadkey
			AND #TEMPBOL.PickSlipNo = TBQ.PickSlipNo
			AND #TEMPBOL.DC = TBQ.DC
			
 /*CS01 End*/			
   
    CREATE TABLE #TEMPPACK (
      Cartonno int,
      Loadkey NVARCHAR(10),
      Orderkey NVARCHAR(10),
      labelno  NVARCHAR(20),    --CS01
      DC       NVARCHAR(20)     --CS01
      )

    -- Modified BY WANYT on 19 Feb 2004 
    INSERT INTO #TEMPPACK (Cartonno, Loadkey, Orderkey,labelno,DC)      --CS01
    SELECT DISTINCT PACKDETAIL.Cartonno ,
                    PACKHEADER.Loadkey,
                    PACKHEADER.Orderkey
                    ,PACKDETAIL.labelno                               --CS01
                    ,PACKDETAIL.RefNo                                 --CS01
    FROM PACKHEADER (NOLOCK), PACKDETAIL (NOLOCK), LOADPLAN (NOLOCK)
    WHERE PACKHEADER.Pickslipno = PACKDETAIL.Pickslipno
      AND PACKHEADER.Loadkey = LOADPLAN.Loadkey 
      AND PACKHEADER.Loadkey between @c_loadkey_start and @c_loadkey_end
      AND LOADPLAN.Facility between @c_facility_start and @c_facility_end 

   Create table #TEMPSUMCTN (
     ShipCtn int,
     Loadkey NVARCHAR(10),
     DC      NVARCHAR(20)                    --(CS01)
      )

   INSERT INTO #TEMPSUMCTN (ShipCtn, Loadkey,DC )
   SELECT ShipCtn = count(#TEMPPACK.labelno),--count(#TEMPPACK.cartonno),      --CS01
          Loadkey,
          DC
   FROM #TEMPPACK
   GROUP BY Loadkey,DC

-- Modified by Vicky 18 June 2003 
   SELECT #TEMPBOL.Loadkey, PODDef07, Carrierkey, ConsigneeKey, C_City, C_Address, Editdate, #TEMPSUMCTN.ShipCtn,
          FreightCost, PODDate01,ShipQty, PodReceivedDate, Adddate, PickSlipNo,#TEMPBOL.DC -- SOS42901   --CS01
   FROM #TEMPBOL--, #TEMPSUMCTN
   LEFT OUTER JOIN #TEMPSUMCTN ON (#TEMPBOL.Loadkey = #TEMPSUMCTN.Loadkey) AND  #TEMPBOL.DC = #TEMPSUMCTN.DC


  DROP TABLE #TEMPBOL
  DROP TABLE #TEMPPACK    
  DROP TABLE #TEMPSUMCTN
END
GO
GRANT EXECUTE ON [dbo].[nsp_Nike_BOL_Summ] TO nSQL 
GO
