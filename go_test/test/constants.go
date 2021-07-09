package test

import "regexp"

var (
	ftAddressPlaceholder     = regexp.MustCompile(`"[^"\s].*/FungibleToken.cdc"`)
	nftAddressPlaceholder    = regexp.MustCompile(`"[^"\s].*/NonFungibleToken.cdc"`)
	leagueAddressPlaceHolder = regexp.MustCompile(`"[^"\s].*/LeagueHeros.cdc"`)
)
