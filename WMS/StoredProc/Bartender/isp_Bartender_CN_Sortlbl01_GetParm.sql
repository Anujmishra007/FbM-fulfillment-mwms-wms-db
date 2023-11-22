SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/*	Copyright: IDS																					*/
/*	Purpose:	isp_Bartender_CN_Sortlbl01_GetParm											*/
/*																										*/
/*	Modifications log:																			*/
/*																										*/
/*	Date		  Rev	 Author		Purposes														*/
/*	2023-08-15 1.0	 CSCHONG		Devops Scripts	Combine & Created	(WMS-23256)		*/
/* 2023-11-16 1.1  ALiang     Performance Tuning (AL01)                       */
/******************************************************************************/

CREATE OR ALTER PROC	[dbo].[isp_Bartender_CN_Sortlbl01_GetParm]
(	@parm01				 NVARCHAR(250),
	@parm02				 NVARCHAR(250),
	@parm03				 NVARCHAR(250),
	@parm04				 NVARCHAR(250),
	@parm05				 NVARCHAR(250),
	@parm06				 NVARCHAR(250),
	@parm07				 NVARCHAR(250),
	@parm08				 NVARCHAR(250),
	@parm09				 NVARCHAR(250),
	@parm10				 NVARCHAR(250),
	@b_debug					INT =	0
)
AS
BEGIN
	SET NOCOUNT	ON
	SET ANSI_NULLS	OFF
	SET QUOTED_IDENTIFIER OFF
	SET CONCAT_NULL_YIELDS_NULL OFF

	DECLARE
		@c_OrderKey			 NVARCHAR(10),
		@c_PrintMbol		 NVARCHAR(1),
		@c_printbyOrder	 NVARCHAR(1),
		@c_Deliverydate	 DATETIME,
		@n_intFlag			 INT,
		@n_CntRec			 INT,
		@c_SQL				 NVARCHAR(4000),
		@c_SQLSORT			 NVARCHAR(4000),
		@c_SQLJOIN			 NVARCHAR(4000),
		@c_condition1		 NVARCHAR(150)	,
		@c_condition2		 NVARCHAR(150),
		@c_SQLGroup			 NVARCHAR(4000),
		@c_SQLOrdBy			 NVARCHAR(150),
		@c_ExecArguments	 NVARCHAR(4000),
		@c_SQLInsert		 NVARCHAR(4000),
		@c_parm01			 NVARCHAR(250),
		@c_parm02			 NVARCHAR(250),
		@c_parm03			 NVARCHAR(250),
		@n_ttlctn			 INT,
		@n_Skuctn			 INT,
		@n_Cartonno			 INT,
		@n_ctnrec			 INT,
		@n_lineno			 INT,
		@n_recid				 INT,
		@c_wavekey			 NVARCHAR(20)


  DECLARE @d_Trace_StartTime	 DATETIME,
			  @d_Trace_EndTime	 DATETIME,
			  @c_Trace_ModuleName NVARCHAR(20),
			  @d_Trace_Step1		 DATETIME,
			  @c_Trace_Step1		 NVARCHAR(20),
			  @c_UserName			 NVARCHAR(20),
			  @n_cntsku				 INT,
			  @c_mode				 NVARCHAR(1),
			  @c_sku					 NVARCHAR(20),
			  @c_getOrderkey		 NVARCHAR(20),
			  @c_getUdef09			 NVARCHAR(30),
			  @c_key01				 NVARCHAR(50),
			  @n_lineCtn			 INT,
			  @n_LineStart			 INT,
			  @c_getparm02			 NVARCHAR(80),
			  @c_getparm03			 NVARCHAR(80),
			  @c_getparm04			 NVARCHAR(80),
			  @c_getparm01			 NVARCHAR(80),
			  @c_getparm06			 NVARCHAR(80),	
			  @c_getparm07			 NVARCHAR(80),
			  @n_getparm10			 INT


	SET @d_Trace_StartTime = GETDATE()
	SET @c_Trace_ModuleName	= ''




  SELECT	 TOP 1 @c_wavekey	= rr.WaveKey
  FROM orders o (nolock),
		 (	select rl.station,rl.orderkey,rl.wavekey,rl.adddate,'' AS position
			  from rdt.rdtPTLPieceLog_log	rl	(nolock)
		 union all
		 select r.station,r.orderkey,r.wavekey,r.adddate,r.Position
			from rdt.rdtPTLPieceLog	r (nolock)
		) rr
where	o.orderkey=rr.orderkey
  and	rr.station=@parm03
  and	o.storerkey=@parm01
order	by	rr.AddDate desc

	 SELECT DISTINCT	PARM1=w.WaveKey,PARM2=o.OrderKey,PARM3=ISNULL(r.position,rrr.Position),PARM4='',PARM5='',PARM6='',PARM7='',
						PARM8='',PARM9='',PARM10='',Key1='',Key2='',Key3='',Key4='',
					 Key5= ''
	FROM wave w	(nolock)
	join orders	o (nolock) on o.userdefine09=w.wavekey
	left join rdt.rdtPTLPieceLog r (nolock) on r.orderkey=o.orderkey
	Left join (	select rr.*
						  from (	select rl.*,row_number() over	(partition by rl.orderkey order by rl.adddate desc) num
									  from rdt.rdtPTLPieceLog_log	rl	(nolock)
                             join codelkup c(nolocK) on c.code=rl.station
                             where c.LISTNAME='TCPClient'   --AL01 Performance Tuning 
                             and c.storerkey='18505'        --AL01 Performance Tuning 
						        ) rr
					where	rr.num=1
				 )	rrr on rrr.orderkey=o.orderkey
		join ( select p.orderkey,sum(p.qty)	qty
					from pickdetail p	(nolock)
			  group by p.orderkey
			) pp on pp.orderkey=o.orderkey
           where	w.WaveKey=@c_wavekey--AL01 Performance Tuning 
           order	by	ISNULL(r.position,rrr.Position)
--	 FROM	orders o	(nolock),
--			( select	rl.station,rl.orderkey,rl.wavekey,rl.adddate,''	AS	position
--				 from	rdt.rdtPTLPieceLog_log rl (nolock)
--		 union all
--		 select r.station,r.orderkey,r.wavekey,r.adddate,r.Position
--			from rdt.rdtPTLPieceLog	r (nolock)
--		) rr
--where o.orderkey=rr.orderkey
--	 and rr.WaveKey =@c_wavekey
--	 and o.storerkey=@parm01
--order by ISNULL(rr.position,'')


	EXIT_SP:

		SET @d_Trace_EndTime	= GETDATE()
		SET @c_UserName =	SUSER_SNAME()


	END -- procedure
GO
GRANT EXECUTE ON [dbo].[isp_Bartender_CN_Sortlbl01_GetParm] TO [NSQL]
GO
