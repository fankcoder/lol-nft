import Market from 0xMARKETADDRESS

// This script gets the matchID of a film in an account's sale collection
// by looking up its unique ID

// Parameters:
//
// sellerAddress: The Flow Address of the account whose sale collection needs to be read
// filmID: The unique ID for the film whose data needs to be read

// Returns: UInt32
// The matchID of film with specified ID

pub fun main(sellerAddress: Address, filmID: UInt64): UInt32 {

    let saleRef = getAccount(sellerAddress).getCapability(/public/topshotSaleCollection)
        .borrow<&{Market.SalePublic}>()
        ?? panic("Could not get public sale reference")

    let token = saleRef.borrowFilm(id: filmID)
        ?? panic("Could not borrow a reference to the specified film")

    let data = token.data

    return data.matchID
}