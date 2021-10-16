# drop databases
Get-DbaDatabase -SqlInstance $s1, $s2, $s3 -Database $databases | Remove-DbaDatabase -Confirm:$false


# drop jobs
Get-DbaAgentJob -SqlInstance $s1, $s2, $s3 | Remove-DbaAgentJob

# drop logins
Get-DbaLogin -SqlInstance $s1, $s2, $s3 -Login CustomLogin, App01, CustomDbOwner | Remove-DbaLogin -Confirm:$false

notepad $profile