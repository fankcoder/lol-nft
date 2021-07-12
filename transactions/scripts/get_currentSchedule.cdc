import LeagueHeros from "../../contracts/LeagueHeros.cdc"

// This script reads the current schedule from the LeagueHeros contract and
// returns that number to the caller

// Returns: UInt32
// currentSeries field in LeagueHeros contract

pub fun main(): UInt32 {

    return LeagueHeros.currentSchedule
}