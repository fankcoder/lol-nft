import League from 0xNFTADDRESS

// This script reads the next Match ID from the League contract and
// returns that number to the caller

// Returns: UInt32
// Value of nextMatchID field in League contract

pub fun main(): UInt32 {

    log(League.nextMatchID)

    return League.nextMatchID
}