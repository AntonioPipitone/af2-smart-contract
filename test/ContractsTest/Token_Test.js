import Contract_Test from "./Contract_Test.js"


export default class Token_Test extends Contract_Test{

    constructor(provider, debug){
        super("AntoTokenSale",provider, debug)
    }

    async runTest(debug){
        await this.buyTest(debug)
    }

    async buyTest(debug){
        const tokenPrice = this.utils.toWei('0.001', 'ether');
        let price = await this.contract.methods.tokenPrice().call();
        console.error(`Il prezzo dei token è ${tokenPrice}? `, price==tokenPrice)
        
        const tokensNumber = 10;
        let buyer = await this.provider.getAccounts()
        const receipt = await this.contract.methods.buyTokens(tokensNumber).send({
            from: buyer[1],
            value: tokensNumber * tokenPrice
        })
        console.error('triggers one event',receipt.events.length == 2 )
    }

}