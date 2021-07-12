import LeagueHeros from "../../contracts/LeagueHeros.cdc"

// This script reads the current number of moments that have been minted
// from the LeagueHeros contract and returns that number to the caller

// Returns: UInt64
// Number of moments minted from LeagueHeros contract

pub fun main(): UInt64 {

    return LeagueHeros.totalSupply
}