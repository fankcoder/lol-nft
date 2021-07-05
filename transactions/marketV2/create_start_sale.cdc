import FungibleToken from 0xFUNGIBLETOKENADDRESS
import LeagueMarketV2 from 0xMARKETV2ADDRESS
import League from 0xNFTADDRESS

transaction(tokenReceiverPath: PublicPath, beneficiaryAccount: Address, cutPercentage: UFix64, momentID: UInt64, price: UFix64) {
    prepare(acct: AuthAccount) {
        // check to see if a sale collection already exists
        if acct.borrow<&LeagueMarketV2.SaleCollection>(from: LeagueMarketV2.marketStoragePath) == nil {
            // get the fungible token capabilities for the owner and beneficiary
            let ownerCapability = acct.getCapability<&{FungibleToken.Receiver}>(tokenReceiverPath)
            let beneficiaryCapability = getAccount(beneficiaryAccount).getCapability<&{FungibleToken.Receiver}>(tokenReceiverPath)

            let ownerCollection = acct.link<&League.Collection>(/private/MomentCollection, target: /storage/MomentCollection)!

            // create a new sale collection
            let topshotSaleCollection <- LeagueMarketV2.createSaleCollection(ownerCollection: ownerCollection, ownerCapability: ownerCapability, beneficiaryCapability: beneficiaryCapability, cutPercentage: cutPercentage)
            
            // save it to storage
            acct.save(<-topshotSaleCollection, to: LeagueMarketV2.marketStoragePath)
        
            // create a public link to the sale collection
            acct.link<&LeagueMarketV2.SaleCollection{LeagueMarketV2.SalePublic}>(LeagueMarketV2.marketPublicPath, target: LeagueMarketV2.marketStoragePath)
        }

        // borrow a reference to the sale
        let topshotSaleCollection = acct.borrow<&LeagueMarketV2.SaleCollection>(from: LeagueMarketV2.marketStoragePath)
            ?? panic("Could not borrow from sale in storage")
        
        // put the moment up for sale
        topshotSaleCollection.listForSale(tokenID: momentID, price: price)
        
    }
}