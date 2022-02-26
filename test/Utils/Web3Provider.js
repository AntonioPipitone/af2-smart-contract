import Web3 from "web3";

export default class Web3Provider{
    constructor(provider = 'HTTP://127.0.0.1:8545'){
        this.web3 = new Web3(new Web3.providers.HttpProvider(provider));
        this.utils = this.web3.utils
    }

    async getAccounts(){
        return await this.web3.eth.getAccounts()
    }
}