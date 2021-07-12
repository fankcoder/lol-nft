import LeagueHeros from "../../../contracts/LeagueHeros.cdc"

// This script returns a boolean indicating if the specified match is locked
// meaning new plays cannot be added to it

// Parameters:
//
// matchID: The unique ID for the match whose data needs to be read

// Returns: Bool
// Whether specified match is locked

pub fun main(matchID: UInt32): Bool {

    let isLocked = LeagueHeros.isMatchLocked(matchID: matchID)
        ?? panic("Could not find the specified match")

    return isLocked
}