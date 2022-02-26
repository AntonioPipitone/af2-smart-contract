const TestToken = artifacts.require('TestToken')
const AntoTokenSale = artifacts.require('AntoTokenSale')
const designVoting = artifacts.require('designVoting')

let TestTokenContract
let AntoTokenSaleContract
let DesignVotingContract

before(async () =>{
    TestTokenContract = await TestToken.new();
    AntoTokenSaleContract = await AntoTokenSale.new(await TestToken.address, 1000000000000000)
    DesignVotingContract = await designVoting.new()

    accounts = await web3.eth.getAccounts()

    for (let account of accounts){
       //await TestTokenContract.approve(accounts[0], account, 100000000)
        console.log(account, await web3.eth.getBalance(account))
    }})

/*for (let i = 0; i < accounts.length; i++) {
    console.log(accounts[i])
}*/

contract('DesignVotingContract', function(accounts){

    it("test_announce", function() {
        return designVoting.deployed().then(function(instance) {
            votingInstance = instance;

        })
    })

})

