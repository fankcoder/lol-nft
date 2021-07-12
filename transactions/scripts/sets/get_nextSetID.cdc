import LeagueHeros from "../../../contracts/LeagueHeros.cdc"

// This script reads the next Match ID from the LeagueHeros contract and
// returns that number to the caller

// Returns: UInt32
// Value of nextMatchID field in LeagueHeros contract

pub fun main(): UInt32 {

    log(LeagueHeros.nextMatchID)

    return LeagueHeros.nextMatchID
}