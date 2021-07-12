import LeagueHeros from "../../../contracts/LeagueHeros.cdc"

// This script reads the public nextPlayID from the LeagueHeros contract and
// returns that number to the caller

// Returns: UInt32
// the nextPlayID field in LeagueHeros contract

pub fun main(): UInt32 {

    log(LeagueHeros.nextPlayID)

    return LeagueHeros.nextPlayID
}