-- FCR-14583: Fn 1764 - Automatic Short Reallocation - Pallet (UOM=1)
-- Storer: PELURINDC | Facility: LUR01
-- Date: 2026-07-31
-- Author: sudhagani-sai-sreeja
--
-- DEPLOYMENT NOTES:
--   Q1: Confirm Supervisor Alert already configured in TaskManagerReason for EMPTY before deploying Section 2.
--   Q2: Replace <LocHoldKey_TBD> with the actual hold code string from PELURINDC client.
--   Q4: Check existing TaskManagerReason row for EMPTY before running Section 2.
--   DevOps items marked [DevOps] must be confirmed before deploying Section 3.

-- =============================================================================
-- SECTION 1: dbo.StorerConfig
-- Wire up ConfirmExtUpdSP and LocHoldKey for PELURINDC / LUR01 / Fn 1764
-- =============================================================================

-- 1a. ConfirmExtUpdSP: routes post-short processing to rdt_1764CfmExtUpd10
IF NOT EXISTS (
   SELECT 1 FROM dbo.StorerConfig WITH (NOLOCK)
   WHERE StorerKey = 'PELURINDC'
     AND Facility  = 'LUR01'
     AND ConfigKey = '1764_ConfirmExtUpdSP'
)
   INSERT INTO dbo.StorerConfig (StorerKey, Facility, ConfigKey, SValue, ConfigDesc)
   VALUES ('PELURINDC', 'LUR01', '1764_ConfirmExtUpdSP', 'rdt_1764CfmExtUpd10',
           'FCR-14583: Short realloc UOM=1 extension SP')
GO

-- 1b. LocHoldKey: hold code applied to pick face on RPF short
--     TODO Q2: Replace <LocHoldKey_TBD> with actual hold code string from client
IF NOT EXISTS (
   SELECT 1 FROM dbo.StorerConfig WITH (NOLOCK)
   WHERE StorerKey = 'PELURINDC'
     AND Facility  = 'LUR01'
     AND ConfigKey = '1764_LocHoldKey'
)
   INSERT INTO dbo.StorerConfig (StorerKey, Facility, ConfigKey, SValue, ConfigDesc)
   VALUES ('PELURINDC', 'LUR01', '1764_LocHoldKey', '<LocHoldKey_TBD>',
           'FCR-14583: Hold code for pick face LOC on short')
GO

-- =============================================================================
-- SECTION 2: dbo.TaskManagerReason
-- Verify EMPTY reason code has DoCycleCount='1' and GenerateAlert='1'
-- NOTE: TaskManagerReason is GLOBAL (no StorerKey). Check existing row first (Q4).
-- If the row already exists with correct values, skip this section.
-- =============================================================================

-- 2a. Check existing row (run as a SELECT before INSERT to satisfy Q4)
-- SELECT * FROM dbo.TaskManagerReason WITH (NOLOCK) WHERE TaskManagerReasonKey = 'EMPTY'

-- 2b. Create EMPTY reason code row if it does not exist
--     TODO Q1: Confirm GenerateAlert='1' is correct (Supervisor Alert requirement)
--     TODO Q4: If row exists, UPDATE only the columns that differ — do not INSERT
IF NOT EXISTS (
   SELECT 1 FROM dbo.TaskManagerReason WITH (NOLOCK)
   WHERE TaskManagerReasonKey = 'EMPTY'
)
   INSERT INTO dbo.TaskManagerReason
      (TaskManagerReasonKey, Descr, DoCycleCount, GenerateAlert, LOCHoldKey,
       RemoveTaskFromUserQueue, ContinueProcessing, TaskStatus)
   VALUES
      ('EMPTY', 'Empty location - short replenishment',
       '1',  -- DoCycleCount: nspRFRSN01 creates CC task
       '1',  -- GenerateAlert: Supervisor alert (Q1: confirm this is already set)
       ' ',  -- LOCHoldKey: LOC hold is handled by SP via StorerConfig, not here
       '0',
       '0',
       'X')
GO

-- =============================================================================
-- SECTION 3: dbo.QCmd_TransmitlogConfig
-- QCommander async reallocation trigger for PELURINDC / 1764ShortPickReallo
-- Environment-specific values (IP, Port, IniFilePath, PhysicalTableName, QCmdClass)
-- must be provided by DevOps before deployment.
-- =============================================================================

IF NOT EXISTS (
   SELECT 1 FROM dbo.QCmd_TransmitlogConfig WITH (NOLOCK)
   WHERE TableName  = '1764ShortPickReallo'
     AND App_Name   = 'WMS'
     AND StorerKey  = 'PELURINDC'
)
   INSERT INTO dbo.QCmd_TransmitlogConfig
      (StorerKey, PhysicalTableName, TableName, App_Name, App_DB_Name,
       StoredProcName, DataStream,
       ThreadPerAcct, ThreadPerStream, MilisecondDelay,
       IP, Port, IniFilePath,
       QCmdClass, TargetDB, CmdType, TaskType)
   VALUES
      ('PELURINDC',
       '<PhysicalTableName_DevOps>',  -- [DevOps] physical queue table name
       '1764ShortPickReallo',
       'WMS',
       '<WMS_DB_Name_DevOps>',        -- [DevOps] WMS database name (App_DB_Name)
       'msp_ProcessShortReplenReAlloc01_PGPE',
       'ShortPick',
       1,    -- ThreadPerAcct
       1,    -- ThreadPerStream
       0,    -- MilisecondDelay
       '<IP_DevOps>',         -- [DevOps] QCommander server IP
       '<Port_DevOps>',       -- [DevOps] QCommander server port
       '<IniFilePath_DevOps>',-- [DevOps] QCommander ini file path
       '<QCmdClass_DevOps>',  -- [DevOps] QCommander class
       '<TargetDB_DevOps>',   -- [DevOps] target database name
       'SQL',
       'D')  -- TaskType: D = detail-level; confirm with DevOps if T (task-level) is needed
GO
