import League from 0xTOPSHOTADDRESS
pub fun main(address: Address): {String: UInt64} {
let account = getAccount(address)
return { "storageUsed": account.storageUsed, "storageCapacity": account.storageCapacity }
}