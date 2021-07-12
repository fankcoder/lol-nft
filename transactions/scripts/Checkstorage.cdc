import LeagueHeros from "../../contracts/LeagueHeros.cdc"
pub fun main(address: Address): {String: UInt64} {
let account = getAccount(address)
return { "storageUsed": account.storageUsed, "storageCapacity": account.storageCapacity }
}