#################################
# CMS - Central Management Server
#################################
#
#
#
# Set the CMS name and servers to register
Clear-Variable CMS, Reg04, Reg06, Reg09
$CMS = 'DC01'             # SQL 2017
$Reg04 = 'DC01\SQL2014'   # SQL 2014
$Reg06 = 'DC01\SQL2016'   # SQL 2016
$Reg09 = 'DC01\SQL2019'   # SQL 2019
Get-Variable -Name 'CMS', 'Reg*'
#
#
#
# Using dbatools.io
# There is even a book to learn more
#                 https://dbatools.io/book
#                 https://www.manning.com/books/learn-dbatools-in-a-month-of-lunches
#
#
#
# Get available GROUPS on CMS
Get-DbaRegServerGroup -SqlInstance $CMS
# <empty> as we did not configure anything yet
#
#
#
# Get available SERVERS on CMS
Get-DbaRegServer -SqlInstance $CMS
# <empty> as we did not configure anything yet
#
#
#
# Add the groups/sub-groups
# PARENT group (requires -Name only)
Add-DbaRegServerGroup -SqlInstance $CMS -Name 01_DEV -Description 'Group for developers'

# CHILD group(s) (besides -Name requires (parent) -Group name /\
Add-DbaRegServerGroup -SqlInstance $CMS -Group 01_DEV -Name Finance -Description 'Group for developers'
Add-DbaRegServerGroup -SqlInstance $CMS -Group 01_DEV -Name Operations -Description 'Group for developers'
Add-DbaRegServerGroup -SqlInstance $CMS -Group 01_DEV -Name IT -Description 'Group for developers'

# PARENT group (requires -Name only)
Add-DbaRegServerGroup -SqlInstance $CMS -Name 02_TEST -Description 'Group for QA'

# CHILD group(s) (besides -Name requires (parent) -Group name /\
Add-DbaRegServerGroup -SqlInstance $CMS -Group 02_TEST -Name Finance -Description 'Group for QA'
Add-DbaRegServerGroup -SqlInstance $CMS -Group 02_TEST -Name Operations -Description 'Group for QA'
Add-DbaRegServerGroup -SqlInstance $CMS -Group 02_TEST -Name IT -Description 'Group for QA'

# PARENT group (requires -Name only)
Add-DbaRegServerGroup -SqlInstance $CMS -Name 03_PROD -Description 'Group for g0ds'

# CHILD group(s) (besides -Name requires (parent) -Group name /\
Add-DbaRegServerGroup -SqlInstance $CMS -Group 03_PROD -Name Finance -Description 'Group for g0ds'
Add-DbaRegServerGroup -SqlInstance $CMS -Group 03_PROD -Name Operations -Description 'Group for g0ds'
Add-DbaRegServerGroup -SqlInstance $CMS -Group 03_PROD -Name IT -Description 'Group for g0ds'

# Get the groups
Get-DbaRegServerGroup -SqlInstance $CMS -Group 01_DEV, 01_DEV\Finance, 03_PROD\Finance, 03_PROD\IT
#
#
#
# Register the servers in CMS
Add-DbaRegServer -SqlInstance $CMS -ServerName $Reg04
Add-DbaRegServer -SqlInstance $CMS -ServerName $Reg06
Add-DbaRegServer -SqlInstance $CMS -ServerName $Reg09
Add-DbaRegServer -SqlInstance $CMS -ServerName $Reg09 -Name 'DoNotDelete :D'
Add-DbaRegServer -SqlInstance $CMS -ServerName $Reg04 -Name $ServerName01
Add-DbaRegServer -SqlInstance $CMS -ServerName $Reg04 -Name $ServerName02
#
#
#
# Register the servers in CMS under groups
Add-DbaRegServer -SqlInstance $CMS -Group 03_PROD\Finance -ServerName $Reg04 
Add-DbaRegServer -SqlInstance $CMS -Group 03_PROD\Finance -ServerName $Reg04 -Name 'CustomNameSQL2014'
Add-DbaRegServer -SqlInstance $CMS -Group 03_PROD\IT      -ServerName $Reg06
Add-DbaRegServer -SqlInstance $CMS -Group 03_PROD\IT      -ServerName $Reg06 # same name, no custom name
Add-DbaRegServer -SqlInstance $CMS -Group 03_PROD\IT      -ServerName $Reg04
Add-DbaRegServer -SqlInstance $CMS -Group 03_PROD\IT      -ServerName $Reg09 
#
#
#
# get available groups on CMS
Get-DbaRegServerGroup -SqlInstance $CMS

# get available servers on CMS
Get-DbaRegServer -SqlInstance $CMS -IncludeSelf


# cleanup
Get-DbaRegServerGroup -SqlInstance $CMS `
    | Remove-DbaRegServerGroup -Confirm:$false
Get-DbaRegServer -SqlInstance $CMS `
    | Remove-DbaRegServer -Confirm:$false
Get-DbaRegServerGroup -SqlInstance $CMS
Get-DbaRegServer -SqlInstance $CMS


