module github.com/fankcoder/lol-nft/lib/go/test

go 1.13

require (
	github.com/fankcoder/lol-nft/lib/go/templates v0.0.0-00010101000000-000000000000
	github.com/onflow/cadence v0.13.10
	github.com/onflow/flow-emulator v0.16.2
	github.com/onflow/flow-go-sdk v0.15.0
	github.com/stretchr/testify v1.7.0
)

replace github.com/fankcoder/lol-nft/lib/go/templates => ../templates

replace github.com/fankcoder/lol-nft/lib/go/contracts => ../contracts
