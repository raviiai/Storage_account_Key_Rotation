https://medium.com/@saurabh.dasgupta1/implementing-a-robust-key-rotation-solution-for-azure-storage-accounts-and-azure-cosmos-db-937ae6932c59

https://faun.pub/automate-the-rotation-of-authentication-credentials-in-azure-b4731295de8f

https://learn.microsoft.com/en-us/azure/storage/common/storage-account-keys-manage?tabs=azure-portal


###########################
### Storage Account Automation
###########################
param (
    [string]$SubscriptionId = "ekjljlj;897jkk"
)

Connect-AzAccount -Identity
Set-AzContext -Subscription $SubscriptionId

$staccs = @(Get-AzStorageAccount)
foreach ($sa in $staccs) {
    Write-Output "======================================================================="
    Write-Output "Rotation For: $($sa.StorageAccountName)" 
    Write-Output "======================================================================="

    $keys = Get-AzStorageAccountKey -ResourceGroupName $sa.ResourceGroupName -Name $sa.StorageAccountName
    $saKey1 = $keys.Value[0]
    $saKey2 = $keys.Value[1]
    
    $lastModifiedKey1 = $saKey1.LastModified
    $lastModifiedKey2 = $saKey2.LastModified

    $currentDate = Get-Date
    $key1Age = ($currentDate - $lastModifiedKey1).Days
    $key2Age = ($currentDate - $lastModifiedKey2).Days

    if ($key1Age -ge 180 -or $key2Age -ge 180) {
        # Rotate keys
        if ($key1Age -ge 180) {
            New-AzStorageAccountKey -ResourceGroupName $sa.ResourceGroupName -Name $sa.StorageAccountName -KeyName key1
            Write-Output "Storage Account Name: $($sa.StorageAccountName) : Key1 Rotated"
        } else {
            Write-Output "Storage Account Name: $($sa.StorageAccountName) : Key1 Rotation Not Needed"
        }

        if ($key2Age -ge 180) {
            New-AzStorageAccountKey -ResourceGroupName $sa.ResourceGroupName -Name $sa.StorageAccountName -KeyName key2
            Write-Output "Storage Account Name: $($sa.StorageAccountName) : Key2 Rotated"
        } else {
            Write-Output "Storage Account Name: $($sa.StorageAccountName) : Key2 Rotation Not Needed"
        }
    } else {
        Write-Output "Storage Account Name: $($sa.StorageAccountName) : Both Keys are within the rotation period"
    }

    Write-Output "-----------------------------------------------------------"
}
