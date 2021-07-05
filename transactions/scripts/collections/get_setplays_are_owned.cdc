import League from 0xNFTADDRESS

// This script checks whether for each MatchID/PlayID combo,
// they own a moment matching that MatchPlay.

// Parameters:
//
// account: The Flow Address of the account whose moment data needs to be read
// matchIDs: A list of unique IDs for the matchs whose data needs to be read
// playIDs: A list of unique IDs for the plays whose data needs to be read

// Returns: Bool
// Whether for each MatchID/PlayID combo,
// account owns a moment matching that MatchPlay.

pub fun main(account: Address, matchIDs: [UInt32], playIDs: [UInt32]): Bool {

    assert(
        matchIDs.length == playIDs.length,
        message: "match and play ID arrays have mismatched lengths"
    )

    let collectionRef = getAccount(account).getCapability(/public/FilmCollection)
                .borrow<&{League.FilmCollectionPublic}>()
                ?? panic("Could not get public moment collection reference")

    let momentIDs = collectionRef.getIDs()

    // For each MatchID/PlayID combo, loop over each moment in the account
    // to see if they own a moment matching that MatchPlay.
    var i = 0

    while i < matchIDs.length {
        var hasMatchingFilm = false
        for momentID in momentIDs {
            let token = collectionRef.borrowFilm(id: momentID)
                ?? panic("Could not borrow a reference to the specified moment")

            let momentData = token.data
            if momentData.matchID == matchIDs[i] && momentData.playID == playIDs[i] {
                hasMatchingFilm = true
                break
            }
        }
        if !hasMatchingFilm {
            return false
        }
        i = i + 1
    }
    
    return true
}