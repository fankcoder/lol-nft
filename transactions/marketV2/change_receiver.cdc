import LeagueMarketV2 from 0xMARKETV2ADDRESS

transaction(receiverPath: PublicPath) {
    prepare(acct: AuthAccount) {

        let topshotSaleCollection = acct.borrow<&LeagueMarketV2.SaleCollection>(from: /storage/topshotSaleCollection)
            ?? panic("Could not borrow from sale in storage")

        topshotSaleCollection.changeOwnerReceiver(acct.getCapability(receiverPath))
    }
}