import fs from "fs";
import path from "path";
import {fileURLToPath} from 'url';

const __filename = fileURLToPath(import.meta.url);

export default class Contract_Test{
    constructor(name, web3_provider, debug){
        this.provider = web3_provider
        this.web3 = this.provider.web3
        this.utils = this.web3.utils
        this.debug = debug

        let pathABI= `../../ABIs/${name}.json`;
        let ABIContract = JSON.parse(fs.readFileSync(path.resolve(path.dirname(__filename), pathABI)));
        let ABIScheduling = ABIContract.abi;
        
        //*Prendi automaticamente l'ultimo address del contratto - SERVE SOLO NEI TEST
        let ContractNetworks = ABIContract.networks
        let ContractAddress = ContractNetworks[Object.keys(ContractNetworks)[Object.keys(ContractNetworks).length - 1]].address
        
        
        console.log(`Indirizzo Contratto ${name} ----- `+ ContractAddress)
        //*Stampalo per check
        this.contract = new this.web3.eth.Contract(ABIScheduling, ContractAddress);
    }

    ArrToObj(arr){
        if (arr == undefined) return undefined
        newObj = {}
        for(let k of Object.keys(arr)){
            if(isNaN(k)) newObj[k]=arr[k]
        }
        return newObj
    }

    runTest(){}
}