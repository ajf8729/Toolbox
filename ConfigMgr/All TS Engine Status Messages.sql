SELECT stat.*, ins.*, att1.*, stat.Time
FROM SMS_StatusMessage AS stat
LEFT JOIN SMS_StatMsgInsStrings as ins
ON ins.RecordID = stat.RecordID
LEFT JOIN SMS_StatMsgAttributes as att1
ON att1.RecordID = stat.RecordID
WHERE stat.Component = "Task Sequence Engine"
AND
stat.Time >= ##PRM:SMS_StatusMessage.Time##
ORDER BY stat.Time DESC