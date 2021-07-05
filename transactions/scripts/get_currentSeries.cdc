import League from 0xNFTADDRESS

// This script reads the current schedule from the League contract and
// returns that number to the caller

// Returns: UInt32
// currentSeries field in League contract

pub fun main(): UInt32 {

    return League.currentSeries
}