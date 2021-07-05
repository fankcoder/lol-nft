import League from 0xNFTADDRESS
pub fun main(address: Address): {String: UInt64} {
let account = getAccount(address)
return { "storageUsed": account.storageUsed, "storageCapacity": account.storageCapacity }
}