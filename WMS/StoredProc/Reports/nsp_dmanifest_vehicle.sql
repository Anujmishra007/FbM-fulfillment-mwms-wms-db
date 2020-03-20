IF EXISTS (SELECT name FROM   dbo.sysobjects WHERE  name = N'nsp_dmanifest_vehicle' AND 	  type = 'P')
    DROP PROCEDURE nsp_dmanifest_vehicle
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Stored Procedure: nsp_dmanifest_vehicle                              */
/* Creation Date: 2007-06-27                                            */
/* Copyright: IDS                                                       */
/* Written by: NickYeo                                                  */
/*                                                                      */
/* Purpose: Create Load Manifest Summary                                */
/*                                                                      */
/* Called By: PB dw: r_dw_dmanifest_vehicle (RCM ReportType 'MANSUM')   */
/*                                                                      */
/* PVCS Version: 1.1                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author    Ver.  Purposes                                 */
/* 2007-06-14  NickYeo   1.0   Added in select for Aquarius Project     */
/* 2007-09-05  ONG01     1.1   Change TranMethod, Carton Count          */
/* 2008-02-29  TTL       1.2   vessel from MBOL not remark              */
/*                             set column limit for remarks, vessel     */
/* 2008-11-24  Audrey    1.3   SOS122509 - bug fix                      */
/* 2010-06-14  Audrey    1.4   SOS177673 - Add in storerkey filtering   */
/* 2011-06-22  NJOW01    1.5   218624 - Add storer.logo                 */
/* 15-Aug-2011 YTWan     1.6   SOS#222245 - Standard getting report logo*/
/*                             (Wan01)                                  */
/* 28-May-2012 NJOW02    1.7   KFMY-Add 2D barcode for ePOD - encrypt   */
/* 24-Mar-2014  TLTING   1.8   SQL2012 Bug                              */
/************************************************************************/

CREATE PROC nsp_dmanifest_vehicle (
    @c_mbolkey NVARCHAR(10)
 )
 AS
 BEGIN
	 SET NOCOUNT ON
	 SET QUOTED_IDENTIFIER OFF
    SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_totalorders  int,
     @n_totalcust    int,
     @n_totalqty    int,
     @c_orderkey    NVARCHAR(10),
     @dc_totalwgt    decimal(7,2),
     @c_orderkey2   NVARCHAR(10),
     @c_prevorder   NVARCHAR(10),
     @c_pickdetailkey NVARCHAR(18),
     @c_sku     NVARCHAR(20),
     @dc_skuwgt     decimal(7,2),
     @n_carton    int,
     @n_totalcarton   int,
     @n_each     int,
     @n_totaleach   int,
     @dc_m3             decimal(7,2)  -- Added By NickYeo on 14-June-2007 (Aquarius Project)
     
   --NJOW02 Start 
   DECLARE @c_epodweburl NVARCHAR(120),
           @c_epodweburlparam NVARCHAR(500)
           /*@c_epodfield NVARCHAR(30),
           @c_epodlabel NVARCHAR(250),
           @c_SQLDYN nNVARCHAR(2000),
           @c_epodfieldvalue NVARCHAR(100),
           @c_TableName NVARCHAR(30),  
           @c_ColumnName NVARCHAR(30),  
           @c_ColumnType NVARCHAR(10)*/  
      
   ---SELECT @c_epodweburl = NSQLDescrip
   ---FROM NSQLCONFIG (NOLOCK)
   ---WHERE Configkey = 'EPODWEBURL'
   --NJOW02 End
      
   SELECT MBOL.mbolkey,
    vessel = convert(NVARCHAR(30), MBOL.vessel),      -- 2008-02-29 TTL
    MBOL.carrierkey,
    MBOLDETAIL.loadkey,
    MBOLDETAIL.orderkey,
    MBOLDETAIL.externorderkey,
    MBOLDETAIL.description,
    MBOLDETAIL.deliverydate,
    totalqty = 0,
    totalorders = 0,
    totalcust = 0,
    MBOL.Departuredate,
    totalwgt = 99999999.99,
    totalcarton = 0,
    totaleach = 0,
    TotalCartons = Orders.ContainerQty, --- mboldetail.totalcartons,  -- ONG01
    MBOL.carrieragent,
    MBOL.drivername,
    remarks = convert(NVARCHAR(255), MBOL.remarks),       -- 2008-02-29 TTL
    ISNULL(dbo.fnc_RTrim(CODELKUP.Long) , MBOL.transmethod) TransMethod,
    MBOL.placeofdelivery,
    MBOL.placeofloading,
    MBOL.placeofdischarge,
    MBOL.otherreference,
    ORDERS.invoiceno,
    ORDERS.route,
    m3 = 99999999.99,
    STORER.Logo,  --NJOW01
    ORDERS.Storerkey,  --(Wan01)
    @c_epodweburlparam AS epodfullurl  --NJOW02
   INTO #RESULT
   FROM MBOL WITH (NOLOCK)
   INNER JOIN MBOLDETAIL WITH (NOLOCK) ON MBOL.mbolkey = MBOLDETAIL.mbolkey
   JOIN ORDERS WITH (NOLOCK) ON MBOLDETAIL.Orderkey = ORDERS.Orderkey
   JOIN STORER WITH (NOLOCK) ON ORDERS.Storerkey = STORER.Storerkey --NJOW01
   LEFT OUTER JOIN CODELKUP WITH (NOLOCK) ON CODELKUP.ListName = 'TRANSMETH' AND CODELKUP.Code = MBOL.transmethod
   WHERE MBOL.mbolkey = @c_mbolkey

   SELECT @n_totalorders = COUNT(*), @n_totalcust = COUNT(DISTINCT description)
   FROM MBOLDETAIL WITH (NOLOCK)
   WHERE mbolkey = @c_mbolkey

   UPDATE #RESULT
   SET totalorders = @n_totalorders,
   totalcust = @n_totalcust
   WHERE mbolkey = @c_mbolkey

   DECLARE cur_1 CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT orderkey FROM #RESULT
   OPEN cur_1
   FETCH NEXT FROM cur_1 INTO @c_orderkey
   WHILE (@@fetch_status <> -1)
      BEGIN
      SELECT @n_totalqty = ISNULL(SUM(qty), 0)
      FROM PICKDETAIL WITH (NOLOCK)
      WHERE orderkey = @c_orderkey

      -- ONG01 BEGIN
      -- Calculate number carton in a pack
      --   SELECT @n_totalcarton = COUNT(DISTINCT PACKD.CartonNo)
      --   FROM packheader PackH (NOLOCK)
      --   JOIN packdetail PACKD (NOLOCK) ON PackH.PickSlipNo = PackD.PickSlipNo
      --   WHERE PAckH.orderkey = @c_orderkey
      
      --NJOW02 Start
      /*
      DECLARE CUR_DYNFLD CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT Description, Long
      FROM CODELKUP (NOLOCK)
      WHERE Listname = 'EPODLABEL'
      ORDER BY Code
      
      OPEN CUR_DYNFLD
      FETCH NEXT FROM CUR_DYNFLD INTO @c_epodlabel, @c_epodfield
      */
      
      ---SET @c_epodweburlparam = 'MY|'+RTRIM(@c_Orderkey)
      /*
      WHILE (@@fetch_status <> -1)  
      BEGIN
         SET @c_TableName = LEFT(@c_epodfield, CharIndex('.', @c_epodfield) - 1)  
         SET @c_ColumnName = SUBSTRING(@c_epodfield,   
                            CharIndex('.', @c_epodfield) + 1, LEN(@c_epodfield) - CharIndex('.', @c_epodfield))  
         
         SELECT @c_ColumnType = DATA_TYPE   
         FROM   INFORMATION_SCHEMA.COLUMNS   
         WHERE  TABLE_NAME = @c_TableName  
         AND    COLUMN_NAME = @c_ColumnName  

         IF @c_TableName = 'ORDERS' AND ISNULL(@c_ColumnType,'') <> ''
         BEGIN                      	                  
            IF @c_ColumnType IN ('datatime')
            BEGIN            	
      	       SELECT @c_SQLDYN = ' SELECT @c_epodfieldvalue = '
      	       + 'CONVERT(NVARCHAR(10),' + RTRIM(@c_epodfield) + ',112) '
               + ' FROM ORDERS WITH (NOLOCK) '  
               + ' WHERE ORDERS.Orderkey = @c_Orderkey '   
            END
            ELSE
            BEGIN
      	       SELECT @c_SQLDYN = ' SELECT @c_epodfieldvalue = '
      	       + 'CONVERT(NVARCHAR(100),' + RTRIM(@c_epodfield) + ') '
               + ' FROM ORDERS WITH (NOLOCK) '  
               + ' WHERE ORDERS.Orderkey = @c_Orderkey '   
            END             
            
            EXEC sp_executesql @c_SQLDYN,   
                 N'@c_Orderkey NVARCHAR(15), @c_epodfieldvalue NVARCHAR(100) OUTPUT',   
                 @c_Orderkey,  
                 @c_epodFieldValue OUTPUT   
             
            SELECT @c_epodweburlparam = @c_epodweburlparam + '|' + RTRIM(@c_epodlabel) + '=' + RTRIM(@c_epodFieldValue)
         END
      	       	       	 
      	 FETCH NEXT FROM CUR_DYNFLD INTO @c_epodlabel, @c_epodfield
      END
      CLOSE CUR_DYNFLD
      DEALLOCATE CUR_DYNFLD   
      */
      
      
      ---IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnc_EncryptURLQueryString]'))       
         ---SET @c_epodweburlparam = dbo.fnc_EncryptURLQueryString(@c_epodweburlparam,'P@sSw0rd')
      ---ELSE IF EXISTS (SELECT * FROM MASTER.sys.objects WHERE object_id = OBJECT_ID(N'[Master].[dbo].[fnc_EncryptURLQueryString]'))
         ---SET @c_epodweburlparam = MASTER.dbo.fnc_EncryptURLQueryString(@c_epodweburlparam,'P@sSw0rd')        
      
      --NJOW02 End                      
   
      UPDATE #RESULT
      SET totalqty = @n_totalqty
      , epodfullurl = @c_Orderkey  ---RTRIM(@c_epodweburl)+RTRIM(@c_epodweburlparam) --NJOW02
      --    ,totalcartons = @n_totalcarton  -- ONG01
      WHERE mbolkey = @c_mbolkey
      AND orderkey = @c_orderkey

      FETCH NEXT FROM cur_1 INTO @c_orderkey
   END
   CLOSE cur_1
   DEALLOCATE cur_1

  SELECT ORDERS.Mbolkey,
   ORDERS.Orderkey,
   totwgt = ISNULL(SUM(PICKDETAIL.Qty),0) * SKU.stdgrosswgt,
   totcs = CASE WHEN PACK.CaseCnt > 0 THEN ISNULL(SUM(PICKDETAIL.Qty),0) / PACK.CaseCnt ELSE 0 END,
   totea = CASE WHEN PACK.CaseCnt > 0 THEN ISNULL(SUM(PICKDETAIL.Qty),0) % CAST (PACK.CaseCnt AS Int) ELSE 0 END,
   m3 = CASE WHEN PACK.CaseCnt > 0 THEN (SKU.[Cube] * ISNULL(SUM(PICKDETAIL.Qty),0)) / (PACK.CaseCnt) ELSE 0 END
  INTO #TEMPCALC
/* -- SOS122509 Start
   FROM PICKDETAIL WITH (NOLOCK), SKU WITH (NOLOCK), PACK WITH (NOLOCK), ORDERS WITH (NOLOCK), ORDERDETAIL WITH (NOLOCK)
   WHERE PICKDETAIL.sku = SKU.sku
   AND PICKDETAIL.Storerkey = SKU.Storerkey
   AND SKU.PackKey = PACK.PackKey
   AND PICKDETAIL.Orderkey = ORDERS.Orderkey
   AND ORDERDETAIL.Orderkey = ORDERS.Orderkey
*/
   FROM PICKDETAIL WITH (NOLOCK)
   INNER JOIN SKU WITH (NOLOCK) ON Pickdetail.sku = Sku.sku
                                   AND (Pickdetail.storerkey = Sku.storerkey) --SOS177673
   INNER JOIN PACK WITH (NOLOCK) ON PickDetail.PackKey = Pack.PackKey
   INNER JOIN ORDERS WITH (NOLOCK) ON (PickDetail.OrderKey = Orders.OrderKey
                                   AND ORDERS.Mbolkey = @c_mbolkey)
-- SOS122509 End
 GROUP BY ORDERS.Mbolkey, ORDERS.Orderkey, PACK.CaseCnt, SKU.stdgrosswgt, SKU.[cube]

 SELECT Mbolkey, Orderkey, totwgt = SUM(totwgt), totcs = SUM(totcs), totea = SUM(totea), m3 = SUM(m3)
 INTO   #TEMPTOTAL
 FROM   #TEMPCALC
 GROUP BY Mbolkey, Orderkey

   UPDATE #RESULT
      SET totalwgt = t.totwgt,
      totalcarton = t.totcs,
      totaleach = t.totea,
      m3 = t.m3
   FROM #TEMPTOTAL t
    WHERE #RESULT.mbolkey = t.Mbolkey
    AND #RESULT.Orderkey = t.Orderkey

   SELECT *
   FROM #RESULT
   ORDER BY loadkey, orderkey

   DROP TABLE #RESULT
   DROP TABLE #TEMPCALC
   DROP TABLE #TEMPTOTAL
 END

GO

GRANT EXECUTE ON nsp_dmanifest_vehicle TO NSQL
GO