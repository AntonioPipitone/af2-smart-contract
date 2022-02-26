import Web3Provider from "./Utils/Web3Provider.js";
import User_Test from "./ContractsTest/User_Test.js";
import OnBoarding_Test from "./ContractsTest/OnBoarding_Test.js";
import Token_Test from "./ContractsTest/Token_Test.js";
import VotingSystem_Test from "./ContractsTest/VotingSystem_Test.js"

async function main(){
    let provider = new Web3Provider()
    var contracts = [new User_Test(provider), new OnBoarding_Test(provider), new Token_Test(provider), new VotingSystem_Test(provider)]

    
    for(let c of contracts){
        await c.runTest()
    }

}

main()