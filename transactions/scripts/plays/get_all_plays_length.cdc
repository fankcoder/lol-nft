import LeagueHeros from "../../../contracts/LeagueHeros.cdc"

// This script returns an array of all the plays 
// that have ever been created for Top Shot

// Returns: [LeagueHeros.Play]
// array of all plays created for Topshot

pub fun main(): Int {

    return LeagueHeros.getAllPlays().length
}