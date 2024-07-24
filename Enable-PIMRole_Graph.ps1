param(
    [Parameter(mandatory=$True, Position=0, ValueFromPipeline=$false)]
    [system.String]$RoleName,

    [Parameter(mandatory=$True, Position=0, ValueFromPipeline=$false)]
    [system.String]$Justification
)

# Connect with admin account and get the TenantID and User ObjectID
Connect-MgGraph
$context = Get-MgContext
$currentUser = (Get-MgUser -UserId $context.Account).Id

# Get all available roles
$myRoles = Get-MgRoleManagementDirectoryRoleEligibilitySchedule -ExpandProperty RoleDefinition -All -Filter "principalId eq '$currentuser'"

# Get SharePoint admin role info
$myRole = $myroles | Where-Object {$_.RoleDefinition.DisplayName -eq $RoleName}

if($myRole){
    
    # Setup parameters for activation
    $params = @{
        Action = "selfActivate"
        PrincipalId = $myRole.PrincipalId
        RoleDefinitionId = $myRole.RoleDefinitionId
        DirectoryScopeId = $myRole.DirectoryScopeId
        Justification = $Justification
        ScheduleInfo = @{
            StartDateTime = Get-Date
            Expiration = @{
                Type = "AfterDuration"
                Duration = "PT2H"
            }
        }
        TicketInfo = @{
            TicketNumber = $null
            TicketSystem = "Service Desk"
        }
    }
    
    # Activate the role
    New-MgRoleManagementDirectoryRoleAssignmentScheduleRequest -BodyParameter $params | fl

    Write-Host "Activation Success for $($RoleName)"
}
else{write-host "Cannot find $($RoleName) in 'My Roles'"}
