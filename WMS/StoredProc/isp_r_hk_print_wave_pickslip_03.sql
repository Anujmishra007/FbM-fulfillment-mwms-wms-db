IF EXISTS (SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'[dbo].[isp_r_hk_print_wave_pickslip_03]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
   DROP PROCEDURE [dbo].[isp_r_hk_print_wave_pickslip_03]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/*************************************************************************/
/* Stored Procedure: isp_r_hk_print_wave_pickslip_03                     */
/*                 modified from nsp_GetPickSlipWave_08 (ver 14-Mar-2012)*/
/* Creation Date: 18-Nov-2020                                            */
/* Copyright: LFL                                                        */
/* Written by: Michael Lam (HK LIT)                                      */
/*                                                                       */
/* Purpose: Discrete Pickslip                                            */
/*                                                                       */
/* Called By: RCM - Popup Pickslip in Loadplan / WavePlan                */
/*            Datawidnow r_hk_print_wave_pickslip_03                     */
/*                                                                       */
/* PVCS Version: 1.0                                                     */
/*                                                                       */
/* Version: 7.0                                                          */
/*                                                                       */
/* Data Modifications:                                                   */
/*                                                                       */
/* Updates:                                                              */
/* Date         Author   Ver  Purposes                                   */
/*************************************************************************/

CREATE PROC [dbo].[isp_r_hk_print_wave_pickslip_03] (
       @c_Wavekey_type   NVARCHAR(13)
)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   SET ANSI_WARNINGS OFF

/* CODELKUP.REPORTCFG
   [MAPFIELD]
      DCC, LineRemark1, LineRemark2, LineRemark3

   [MAPVALUE]

   [SHOWFIELD]
      Consigneekey, DCC, LineRemark1, LineRemark2, LineRemark3
      HideLottable01, HideAltSku
*/
   DECLARE @c_DataWindow       NVARCHAR(40)  = 'r_hk_print_wave_pickslip_03'
         , @n_continue         INT           = 1
         , @n_StartTCnt        INT           = @@TRANCOUNT
         , @c_Wavekey          NVARCHAR(10)  = LEFT(@c_Wavekey_type, 10)
         , @c_Type             NVARCHAR(2)   = RIGHT(@c_Wavekey_type,2)
         , @c_Pickheaderkey    NVARCHAR(10)
         , @c_Orderkey         NVARCHAR(10)
         , @c_errmsg           NVARCHAR(255)
         , @b_success          INT
         , @n_err              INT
         , @c_Storerkey        NVARCHAR(15)
         , @c_Storer_Logo      NVARCHAR(60)
         , @c_ExecStatements   NVARCHAR(MAX)
         , @c_ExecArguments    NVARCHAR(MAX)
         , @c_ShowFields       NVARCHAR(MAX)
         , @c_DCCExp           NVARCHAR(MAX)
         , @c_LineRemark1Exp   NVARCHAR(MAX)
         , @c_LineRemark2Exp   NVARCHAR(MAX)
         , @c_LineRemark3Exp   NVARCHAR(MAX)

   IF OBJECT_ID('tempdb..#TEMP_PIKDT') IS NOT NULL
      DROP TABLE #TEMP_PIKDT

   -- Use Zone as a UOM Picked 1 - Pallet, 2 - Case, 6 - Each, 8 - By Order
   -- Update PickType: 0=New, 1=Reprint
   IF EXISTS(SELECT TOP 1 1 FROM PICKHEADER (NOLOCK) WHERE Wavekey = @c_Wavekey AND Zone = '8')
   BEGIN
      BEGIN TRAN

      UPDATE dbo.PICKHEADER WITH(ROWLOCK)
         SET PickType = '1'
           , EditDate = GETDATE()
           , EditWho  = SUSER_SNAME()
           , TrafficCop = NULL
       WHERE WaveKey = @c_Wavekey
         AND Zone = '8'
         AND PickType = '0'

      SELECT @n_err = @@ERROR
      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         IF @@TRANCOUNT >= 1
         BEGIN
            ROLLBACK TRAN
            GOTO QUIT
         END
      END
      ELSE
      BEGIN
         IF @@TRANCOUNT > 0
            COMMIT TRAN
         ELSE
         BEGIN
            SELECT @n_continue = 3
            ROLLBACK TRAN
            GOTO QUIT
         END
      END
   END

   WHILE @@TRANCOUNT > 0
      COMMIT TRAN


   -- Generate PickHeader
   DECLARE PICK_CUR CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
    SELECT DISTINCT OH.Orderkey
      FROM dbo.WAVEDETAIL WD (NOLOCK)
      JOIN dbo.ORDERS     OH (NOLOCK) ON WD.Orderkey = OH.Orderkey
      JOIN dbo.PICKDETAIL PD (NOLOCK) ON WD.Orderkey = PD.Orderkey
      LEFT JOIN dbo.PICKHEADER PH (NOLOCK) ON WD.Orderkey = PH.Orderkey AND WD.Wavekey = PH.Wavekey AND PH.Zone='8'
      LEFT JOIN dbo.PICKHEADER PH2(NOLOCK) ON OH.Loadkey  = PH2.ExternOrderkey AND ISNULL(PH2.Orderkey,'')='' AND ISNULL(PH2.Zone,'')<>'8' AND ISNULL(OH.Loadkey,'')<>''
    WHERE WD.wavekey = @c_Wavekey
      AND OH.Userdefine08 = 'Y' -- only for wave plan OH.
      AND PD.Status < '5'
      AND (PD.Pickmethod = '8' OR PD.Pickmethod = '')
      AND PH.PickHeaderKey IS NULL
      AND PH2.PickHeaderKey IS NULL
    ORDER BY 1

   OPEN PICK_CUR

   WHILE 1=1
   BEGIN
      FETCH NEXT FROM PICK_CUR INTO @c_Orderkey

      IF @@FETCH_STATUS<>0
         BREAK

      EXECUTE nspg_GetKey
              'PICKSLIP'
            , 9
            , @c_Pickheaderkey OUTPUT
            , @b_success       OUTPUT
            , @n_err           OUTPUT
            , @c_errmsg        OUTPUT

      SELECT @c_Pickheaderkey = 'P' + @c_Pickheaderkey

      BEGIN TRAN

      INSERT INTO dbo.PICKHEADER WITH(ROWLOCK)
             (PickHeaderKey   , OrderKey   , WaveKey   , PickType, Zone, TrafficCop)
      VALUES (@c_Pickheaderkey, @c_Orderkey, @c_Wavekey, '0'     , '8' ,  ''       )

      SELECT @n_err = @@ERROR
      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         ROLLBACK TRAN
         GOTO QUIT
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > 0
            COMMIT TRAN
      END
   END

   CLOSE PICK_CUR
   DEALLOCATE PICK_CUR



   CREATE TABLE #TEMP_PIKDT (
        Wavekey          NVARCHAR(10)
      , Storerkey        NVARCHAR(15)
      , StorerCompany    NVARCHAR(45)
      , PickSlipNo       NVARCHAR(18)
      , OrderKey         NVARCHAR(10)
      , ExternOrderKey   NVARCHAR(63)
      , ExternPOKey      NVARCHAR(20)
      , BuyerPO          NVARCHAR(20)
      , InvoiceNo        NVARCHAR(20)
      , DeliveryDate     DATETIME
      , ConsigneeKey     NVARCHAR(15)
      , Company          NVARCHAR(45)
      , Addr1            NVARCHAR(45)
      , Addr2            NVARCHAR(45)
      , Addr3            NVARCHAR(45)
      , PostCode         NVARCHAR(18)
      , Route            NVARCHAR(10)
      , Route_Desc       NVARCHAR(60)
      , TrfRoom          NVARCHAR(10)
      , PrintedFlag      NVARCHAR(1)
      , LabelPrice       NVARCHAR(5)
      , PendingFlag      NVARCHAR(30)
      , Notes1           NVARCHAR(500)
      , Notes2           NVARCHAR(500)
      , SKU              NVARCHAR(20)
      , SkuDesc          NVARCHAR(60)
      , Putawayzone      NVARCHAR(10)
      , ZoneDesc         NVARCHAR(60)
      , LogicalLocation  NVARCHAR(18)
      , LOC              NVARCHAR(10)
      , ID               NVARCHAR(18)
      , AltSKU           NVARCHAR(20)
      , SUSR2            NVARCHAR(20)
      , BUSR8            NVARCHAR(30)
      , BUSR10           NVARCHAR(30)
      , Lottable01       NVARCHAR(18)
      , Lottable02       NVARCHAR(18)
      , Lottable03       NVARCHAR(18)
      , Lottable04       DATETIME
      , Qty              INT
      , CaseCnt          INT
      , InnerPack        INT
      , PackUOM1         NVARCHAR(10)
      , PackUOM2         NVARCHAR(10)
      , PackUOM3         NVARCHAR(10)
      , Cartons          INT
      , Inners           INT
      , Pieces           INT
      , StdCube          FLOAT
      , StdGrossWgt      FLOAT
      , DCC              NVARCHAR(30)
      , LineRemark1      NVARCHAR(500)
      , LineRemark2      NVARCHAR(500)
      , LineRemark3      NVARCHAR(500)
      , DWName           NVARCHAR(40)
      , ShowFields       NVARCHAR(4000)
      , Storer_Logo      NVARCHAR(60)
   )


   -- Storerkey Loop
   DECLARE C_CUR_STORERKEY CURSOR FAST_FORWARD READ_ONLY FOR
   SELECT DISTINCT PD.Storerkey
     FROM dbo.WAVEDETAIL   WD   (NOLOCK)
     JOIN dbo.ORDERS       OH   (NOLOCK) ON WD.Orderkey = OH.Orderkey
     JOIN dbo.PICKHEADER   PH   (NOLOCK) ON WD.Orderkey = PH.Orderkey AND WD.Wavekey = PH.Wavekey AND PH.Zone='8'
     JOIN dbo.PICKDETAIL   PD   (NOLOCK) ON WD.Orderkey = PD.Orderkey
    WHERE WD.wavekey = @c_Wavekey
      AND OH.Userdefine08 = 'Y'
      AND OH.Status >= '1' AND OH.Status <= '9'
      AND ( PD.Pickmethod = '8' OR PD.Pickmethod = ' ' )
    ORDER BY 1

   OPEN C_CUR_STORERKEY

   WHILE 1=1
   BEGIN
      FETCH NEXT FROM C_CUR_STORERKEY
       INTO @c_Storerkey

      IF @@FETCH_STATUS<>0
         BREAK

      SELECT @c_ShowFields     = ''
           , @c_Storer_Logo    = ''
           , @c_DCCExp         = ''
           , @c_LineRemark1Exp = ''
           , @c_LineRemark2Exp = ''
           , @c_LineRemark3Exp = ''

      SELECT TOP 1
             @c_ShowFields = LTRIM(RTRIM(UDF01)) + LOWER(LTRIM(RTRIM(Notes))) + LTRIM(RTRIM(UDF01))
      FROM dbo.CODELKUP (NOLOCK)
      WHERE Listname='REPORTCFG' AND Code='SHOWFIELD' AND Long=@c_DataWindow AND Short='Y'
         AND Storerkey = @c_Storerkey
       ORDER BY Code2

      SELECT TOP 1
             @c_Storer_Logo = RTRIM( ISNULL( RL.Notes, '') )
        FROM dbo.CODELKUP RL(NOLOCK)
       WHERE Listname='RPTLOGO' AND Code='LOGO' AND Long=@c_DataWindow
         AND Storerkey = @c_Storerkey
       ORDER BY Code2


      SELECT TOP 1
             @c_DCCExp         = ISNULL(RTRIM((select top 1 b.ColValue
                                 from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                 where a.SeqNo=b.SeqNo and a.ColValue='DCC')), '' )
           , @c_LineRemark1Exp = ISNULL(RTRIM((select top 1 b.ColValue
                                 from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                 where a.SeqNo=b.SeqNo and a.ColValue='LineRemark1')), '' )
           , @c_LineRemark2Exp = ISNULL(RTRIM((select top 1 b.ColValue
                                 from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                 where a.SeqNo=b.SeqNo and a.ColValue='LineRemark2')), '' )
           , @c_LineRemark3Exp = ISNULL(RTRIM((select top 1 b.ColValue
                                 from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                 where a.SeqNo=b.SeqNo and a.ColValue='LineRemark3')), '' )
        FROM dbo.CODELKUP (NOLOCK)
       WHERE Listname='REPORTCFG' AND Code='MAPFIELD' AND Long=@c_DataWindow AND Short='Y'
         AND Storerkey = @c_Storerkey
       ORDER BY Code2


      SET @c_ExecStatements =
        N'INSERT INTO #TEMP_PIKDT ('
        +    ' Wavekey, Storerkey, StorerCompany, PickSlipNo, OrderKey, ExternOrderKey, ExternPOKey, BuyerPO, InvoiceNo, DeliveryDate'
        +   ', ConsigneeKey, Company, Addr1, Addr2, Addr3, PostCode, Route, Route_Desc, TrfRoom, PrintedFlag'
        +   ', LabelPrice, PendingFlag, Notes1, Notes2, SKU, SkuDesc, Putawayzone, ZoneDesc, LogicalLocation, LOC'
        +   ', ID, AltSKU, SUSR2, BUSR8, BUSR10, Lottable01, Lottable02, Lottable03, Lottable04, Qty'
        +   ', CaseCnt, InnerPack, PackUOM1, PackUOM2, PackUOM3, StdCube, StdGrossWgt, DCC, LineRemark1, LineRemark2'
        +   ', LineRemark3, DWName, ShowFields, Storer_Logo)'

      SET @c_ExecStatements = @c_ExecStatements
        + ' SELECT Wavekey          = RTRIM( ISNULL( WD.Wavekey, '''') )'
        +       ', Storerkey        = RTRIM( ISNULL( PD.Storerkey, '''') )'
        +       ', StorerCompany    = RTRIM( ISNULL( ST.Company, '''') )'
        +       ', PickSlipNo       = RTRIM( ISNULL( PH.PickheaderKey, '''') )'
        +       ', OrderKey         = RTRIM( ISNULL( PD.Orderkey, '''') )'
        +       ', ExternOrderKey   = RTRIM( ISNULL( OH.ExternOrderKey, '''') ) + '' (''+RTRIM( ISNULL(OH.Type, '''') )+'')'''
        +       ', ExternPOKey      = RTRIM( ISNULL( OH.ExternPoKey, '''') )'
        +       ', BuyerPO          = RTRIM( ISNULL( OH.BuyerPO, '''') )'
        +       ', InvoiceNo        = RTRIM( ISNULL( OH.InvoiceNo, '''') )'
        +       ', DeliveryDate     = OH.DeliveryDate'
        +       ', ConsigneeKey     = RTRIM( ISNULL( ' + CASE WHEN @c_ShowFields LIKE '%,Consigneekey,%'   THEN 'OH.Consigneekey' ELSE 'OH.BillToKey'  END + ', '''') )'
        +       ', Company          = RTRIM( ISNULL( OH.C_Company, '''') )'
        +       ', Addr1            = RTRIM( ISNULL( OH.C_Address1, '''') )'
        +       ', Addr2            = RTRIM( ISNULL( OH.C_Address2, '''') )'
        +       ', Addr3            = RTRIM( ISNULL( OH.C_Address3, '''') )'
        +       ', PostCode         = RTRIM( ISNULL( OH.C_Zip, '''') )'
        +       ', Route            = RTRIM( ISNULL( OH.Route, '''') )'
        +       ', Route_Desc       = RTRIM( ISNULL( RT.Descr, '''') )'
        +       ', TrfRoom          = RTRIM( ISNULL( OH.Door, '''') )'
        +       ', PrintedFlag      = CASE WHEN PH.PickType = ''1'' THEN ''Y'' ELSE ''N'' END'
        +       ', LabelPrice       = RTRIM( ISNULL( OH.LabelPrice, ''N'') )'
        +       ', PendingFlag      = RTRIM( ISNULL( OH.RDD, '''') )'
        +       ', Notes1           = RTRIM( ISNULL( OH.Notes, '''') )'
        +       ', Notes2           = RTRIM( ISNULL( OH.Notes2, '''') )'
      SET @c_ExecStatements = @c_ExecStatements
        +       ', SKU              = RTRIM( ISNULL( PD.Sku,'''') )'
        +       ', SkuDesc          = RTRIM( ISNULL( SKU.Descr,'''') )'
        +       ', Putawayzone      = RTRIM( ISNULL( CASE WHEN PD.ToLoc<>'''' THEN TOLOC.Putawayzone ELSE LOC.Putawayzone END, '''') )'
        +       ', ZoneDesc         = RTRIM( ISNULL( CASE WHEN PD.ToLoc<>'''' THEN TOPA.Descr ELSE PA.Descr END, '''') )'
        +       ', LogicalLocation  = RTRIM( ISNULL( LOC.LogicalLocation, '''') )'
        +       ', LOC              = RTRIM( ISNULL( CASE WHEN PD.ToLoc<>'''' THEN PD.ToLoc ELSE PD.Loc END,'''') )'
        +       ', ID               = RTRIM( ISNULL( PD.ID, '''') )'
        +       ', AltSKU           = RTRIM( ISNULL( ' + CASE WHEN @c_ShowFields LIKE '%,HideAltSku,%'     THEN 'NULL'            ELSE 'SKU.AltSKU'    END + ', '''') )'
        +       ', SUSR2            = RTRIM( ISNULL( ' + CASE WHEN @c_ShowFields LIKE '%,Consigneekey,%'   THEN 'SHPTO.SUSR2'     ELSE 'BILTO.SUSR2'   END + ', '''') )'
        +       ', BUSR8            = RTRIM( ISNULL( SKU.BUSR8, '''') )'
        +       ', BUSR10           = RTRIM( ISNULL( SKU.BUSR10, '''') )'
        +       ', Lottable01       = RTRIM( ISNULL( ' + CASE WHEN @c_ShowFields LIKE '%,HideLottable01,%' THEN 'NULL'            ELSE 'LA.Lottable01' END + ', '''') )'
        +       ', Lottable02       = RTRIM( ISNULL( LA.Lottable02,'''') )'
        +       ', Lottable03       = RTRIM( ISNULL( LA.Lottable03, '''') )'
        +       ', Lottable04       = LA.Lottable04'
        +       ', Qty              = PD.Qty'
        +       ', CaseCnt          = PACK.CaseCnt'
        +       ', InnerPack        = PACK.InnerPack'
        +       ', PackUOM1         = RTRIM( ISNULL( PACK.PackUOM1, '''') )'
        +       ', PackUOM2         = RTRIM( ISNULL( PACK.PackUOM2, '''') )'
        +       ', PackUOM3         = RTRIM( ISNULL( PACK.PackUOM3, '''') )'
        +       ', StdCube          = ISNULL( SKU.StdCube,0.0)'
        +       ', StdGrossWgt      = ISNULL( SKU.StdGrossWgt,0.0)'
      SET @c_ExecStatements = @c_ExecStatements
        +       ', DCC              = ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_DCCExp        ,'')<>'' THEN @c_DCCExp         ELSE 'NULL' END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
        +       ', LineRemark1      = ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_LineRemark1Exp,'')<>'' THEN @c_LineRemark1Exp ELSE 'NULL' END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
        +       ', LineRemark2      = ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_LineRemark2Exp,'')<>'' THEN @c_LineRemark2Exp ELSE 'NULL' END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
        +       ', LineRemark3      = ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_LineRemark3Exp,'')<>'' THEN @c_LineRemark3Exp ELSE 'NULL' END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
        +       ', DWName           = @c_DataWindow'
        +       ', ShowFields       = RTRIM( ISNULL( @c_ShowFields, '''') )'
        +       ', Storer_Logo      = RTRIM( ISNULL( @c_Storer_Logo, '''') )'

      SET @c_ExecStatements = @c_ExecStatements
        +   ' FROM dbo.WAVEDETAIL   WD   (NOLOCK)'
        +   ' JOIN dbo.ORDERS       OH   (NOLOCK) ON WD.Orderkey = OH.Orderkey'
        +   ' JOIN dbo.PICKHEADER   PH   (NOLOCK) ON WD.Orderkey = PH.Orderkey AND WD.Wavekey = PH.Wavekey AND PH.Zone=''8'''
        +   ' JOIN dbo.PICKDETAIL   PD   (NOLOCK) ON WD.Orderkey = PD.Orderkey'
        +   ' JOIN dbo.PACK         PACK (NOLOCK) ON PD.Packkey = PACK.Packkey'
        +   ' JOIN dbo.LOC          LOC  (NOLOCK) ON PD.Loc = LOC.Loc'
        +   ' JOIN dbo.SKU          SKU  (NOLOCK) ON PD.Storerkey = SKU.Storerkey AND PD.Sku = SKU.Sku'
        +   ' JOIN dbo.LOTATTRIBUTE LA   (NOLOCK) ON PD.Lot = LA.Lot'
        +   ' JOIN dbo.STORER       ST   (NOLOCK) ON PD.Storerkey = ST.Storerkey'
        +   ' LEFT JOIN dbo.ROUTEMASTER  RT   (NOLOCK) ON OH.Route = RT.Route'
        +   ' LEFT JOIN dbo.PUTAWAYZONE  PA   (NOLOCK) ON LOC.PutawayZone = PA.PutawayZone'
        +   ' LEFT JOIN dbo.LOC          TOLOC(NOLOCK) ON PD.ToLoc = TOLOC.Loc AND ISNULL(PD.ToLoc,'''')<>'''''
        +   ' LEFT JOIN dbo.PUTAWAYZONE  TOPA (NOLOCK) ON TOLOC.PutawayZone = TOPA.PutawayZone'
        +   ' LEFT JOIN dbo.STORER       SHPTO(NOLOCK) ON OH.Consigneekey = SHPTO.Storerkey'
        +   ' LEFT JOIN dbo.STORER       BILTO(NOLOCK) ON OH.BillToKey = BILTO.Storerkey'

      SET @c_ExecStatements = @c_ExecStatements
        +   ' WHERE WD.wavekey = @c_Wavekey'
        +     ' AND PD.Storerkey = @c_Storerkey'
        +     ' AND OH.Userdefine08 = ''Y'''
        +     ' AND OH.Status >= ''1'' AND OH.Status <= ''9'''
        +     ' AND ( PD.Pickmethod = ''8'' OR PD.Pickmethod = '' '' )'

      SET @c_ExecArguments = N'@c_DataWindow  NVARCHAR(40)'
                           + ',@c_ShowFields  NVARCHAR(MAX)'
                           + ',@c_Wavekey     NVARCHAR(10)'
                           + ',@c_Storerkey   NVARCHAR(15)'
                           + ',@c_Storer_Logo NVARCHAR(60)'

      EXEC sp_ExecuteSql @c_ExecStatements
                       , @c_ExecArguments
                       , @c_DataWindow
                       , @c_ShowFields
                       , @c_Wavekey
                       , @c_Storerkey
                       , @c_Storer_Logo
   END
   CLOSE C_CUR_STORERKEY
   DEALLOCATE C_CUR_STORERKEY



   SELECT Wavekey         = UPPER( X.Wavekey )
        , Storerkey       = UPPER( X.Storerkey )
        , StorerCompany   = MAX( X.StorerCompany )
        , PickSlipNo      = UPPER( X.PickSlipNo )
        , OrderKey        = UPPER( X.OrderKey )
        , ExternOrderKey  = MAX( X.ExternOrderKey )
        , ExternPOKey     = MAX( X.ExternPOKey )
        , BuyerPO         = MAX( X.BuyerPO )
        , InvoiceNo       = MAX( X.InvoiceNo )
        , DeliveryDate    = MAX( X.DeliveryDate )
        , ConsigneeKey    = UPPER( MAX( X.ConsigneeKey ) )
        , Company         = MAX( X.Company )
        , Addr1           = MAX( X.Addr1 )
        , Addr2           = MAX( X.Addr2 )
        , Addr3           = MAX( X.Addr3 )
        , PostCode        = MAX( X.PostCode )
        , Route           = MAX( X.Route )
        , Route_Desc      = MAX( X.Route_Desc )
        , TrfRoom         = MAX( X.TrfRoom )
        , PrintedFlag     = MAX( X.PrintedFlag )
        , LabelPrice      = MAX( X.LabelPrice )
        , PendingFlag     = MAX( X.PendingFlag )
        , Notes1          = MAX( X.Notes1 )
        , Notes2          = MAX( X.Notes2 )
        , SKU             = UPPER( X.SKU )
        , SkuDesc         = MAX( X.SkuDesc )
        , Putawayzone     = UPPER( MAX( X.Putawayzone ) )
        , ZoneDesc        = MAX( X.ZoneDesc )
        , LogicalLocation = UPPER( MAX( X.LogicalLocation ) )
        , LOC             = UPPER( X.LOC )
        , ID              = UPPER( X.ID )
        , AltSKU          = MAX( X.AltSKU )
        , SUSR2           = MAX( X.SUSR2 )
        , BUSR8           = MAX( X.BUSR8 )
        , BUSR10          = UPPER( MAX( X.BUSR10 ) )
        , Lottable01      = UPPER( X.Lottable01 )
        , Lottable02      = UPPER( X.Lottable02 )
        , Lottable03      = UPPER( X.Lottable03 )
        , Lottable04      = X.Lottable04
        , Qty             = SUM( X.Qty )
        , CaseCnt         = MAX( X.CaseCnt )
        , InnerPack       = MAX( X.InnerPack )
        , PackUOM1        = MAX( X.PackUOM1 )
        , PackUOM2        = MAX( X.PackUOM2 )
        , PackUOM3        = MAX( X.PackUOM3 )
        , Cartons         = CASE WHEN ISNULL(MAX(X.CaseCnt  ),0)=0 THEN 0 ELSE FLOOR(SUM(X.Qty) / MAX(X.CaseCnt)) END
        , Inners          = CASE WHEN ISNULL(MAX(X.InnerPack),0)=0 THEN 0 ELSE FLOOR( IIF(ISNULL(MAX(X.CaseCnt),0)=0, SUM(X.Qty), SUM(X.Qty) % MAX(X.CaseCnt)) / MAX(X.InnerPack)) END
        , Pieces          = CASE WHEN ISNULL(MAX(X.InnerPack),0)=0 THEN IIF(ISNULL(MAX(X.CaseCnt),0)=0, SUM(X.Qty), SUM(X.Qty) % MAX(X.CaseCnt))
                                                                   ELSE IIF(ISNULL(MAX(X.CaseCnt),0)=0, SUM(X.Qty), SUM(X.Qty) % MAX(X.CaseCnt)) % MAX(X.InnerPack) END
        , StdCube         = MAX( X.StdCube )
        , StdGrossWgt     = MAX( X.StdGrossWgt )
        , DCC             = X.DCC
        , LineRemark1     = X.LineRemark1
        , LineRemark2     = X.LineRemark2
        , LineRemark3     = X.LineRemark3
        , DWName          = MAX( X.DWName )
        , ShowFields      = MAX( X.ShowFields )
        , Storer_Logo     = MAX( X.Storer_Logo )
   FROM #TEMP_PIKDT X
   GROUP BY X.Wavekey
          , X.Storerkey
          , X.PickSlipNo
          , X.OrderKey
          , X.SKU
          , X.LOC
          , X.ID
          , X.Lottable01
          , X.Lottable02
          , X.Lottable03
          , X.Lottable04
          , X.DCC
          , X.LineRemark1
          , X.LineRemark2
          , X.LineRemark3
    ORDER BY Orderkey, ZoneDesc, LogicalLocation, Loc

QUIT:
   WHILE @@TRANCOUNT < @n_StartTCnt
      BEGIN TRAN

   IF @n_continue=3
   BEGIN
      SELECT @b_success = 0
      IF @@TRANCOUNT > @n_StartTCnt
         ROLLBACK TRAN
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartTCnt
            COMMIT TRAN
      END
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'isp_r_hk_print_wave_pickslip_03'
      RETURN
   END
   ELSE
   BEGIN
      SELECT @b_success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
         COMMIT TRAN
      RETURN
   END
END
GO
GRANT EXECUTE ON isp_r_hk_print_wave_pickslip_03 TO NSQL
GO