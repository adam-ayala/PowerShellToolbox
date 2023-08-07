---
external help file: PowerShellToolbox-help.xml
Module Name: PowerShellToolbox
online version: https://github.com/adam-ayala/PowerShellToolbox
schema: 2.0.0
---

# Write-LogEntry

## SYNOPSIS
Writes a detailed and informational log entry

## SYNTAX

```
Write-LogEntry [-Value] <String> [-Severity <String>] [-FileName <String>] [-LogsDirectory <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Writes a detailed and informational log entry

## EXAMPLES

### EXAMPLE 1
```
Write-LogEntry -Value "This is a message" -Severity 2
```

Writes a log entry

## PARAMETERS

### -Value
Writes an informational log entry

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Severity
Severity for the log entry.
1 for Informational, 2 for Warning and 3 for Error.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 1
Accept pipeline input: False
Accept wildcard characters: False
```

### -FileName
Name of the log file that the entry will written to.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: OSDkit.log
Accept pipeline input: False
Accept wildcard characters: False
```

### -LogsDirectory
Path to the logging directory.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### None
## NOTES
This function is only useful during a Task Sequence or Windows operating system deployment
Part of the Operating System Deployment Kit

## RELATED LINKS

[https://github.com/adam-ayala/PowerShellToolbox](https://github.com/adam-ayala/PowerShellToolbox)

