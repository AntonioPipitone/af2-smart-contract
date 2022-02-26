const bs58=require('bs58');
const fs=require('fs');
var path = require('path')
class blockchain{
    constructor(){
        this.Web3 = require('web3');
        this.provider="HTTP://127.0.0.1:7545";
        this.web3Provider=new this.Web3.providers.HttpProvider(this.provider);
        this.web3 = new this.Web3(this.web3Provider);
        var pathABI= "../build/contracts/VotingSystem.json";
        var ABIContract = JSON.parse(fs.readFileSync(path.resolve(__dirname, pathABI)));
        var ABIVoting = ABIContract.abi;
        //*Prendi automaticamente l'ultimo address del contratto - SERVE SOLO NEI TEST
        this.ContractNetworks = ABIContract['networks']
        this.ContractAddress = this.ContractNetworks[Object.keys(this.ContractNetworks)[Object.keys(this.ContractNetworks).length - 1]].address
        this.contract = new this.web3.eth.Contract(ABIVoting,this.ContractAddress);

        this.hash=bs58.decode("QmPZ9gcCEpqKTo6aq61g2nXGUhM4iCL3ewB6LDXZCtioEB").slice(2);
     }

     sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
      }

      async callProva(){
          let res=this.contract.methods.prova(this.hash).call();
          return res;
      }

      async convertToIpfsHash(val){
            console.log(val);
            val=val.slice(2);
            let buff=Buffer.from(`1220${val}`, "hex");
            console.log(bs58.encode(buff));

      }
      async addPlayer(users){

        for(let user of users){
            this.contract.methods.addPlayer().send({from:user,gas:3000000});
        
        }
     }

     async announce(user){
        this.contract.methods.announce(this.web3.utils.fromAscii("test1"),Date.now(),this.web3.utils.toWei('3'),1,1).send({from: user, gas: 3000000, value: this.web3.utils.toWei('3'),gasPrice:0}).then(res =>{ 
            if(res)
                console.log('Announcement made-----------------------', res)});
        
        await this.contract.methods.getNumDesignes().call().then((designe)=>{
                    console.log("NUmber of desgn:-----------------------"+designe)
                });

     }


     async register(users,index){
         for(let user of users)
            this.contract.methods.register(index,1).send({from: user, gas: 3000000, value: this.web3.utils.fromWei('1000000000000000000'),gasPrice:0});
     }

    async voting(users,index,vote){
        for(let user of users)
            this.contract.methods.vote(index,vote,Date.now(),this.web3.utils.fromWei('1000000000000000000')).send({from: user, gas: 3000000, value: this.web3.utils.fromWei('1000000000000000000'),gasPrice:0}).then((val)=>{
                if(val)
                    console.log("The votation was successfull--------")
            });
        
    }

    async checkResult(index){
        let res=this.contract.methods.checkResult(index,Date.now()).call().then((resolu)=>{;
        if(resolu==1)
            console.log("Passed");
        else console.log("Failed");});
    }

    async calculateResult(announcer,index){
        this.contract.methods.calculateResult(index,Date.now()).send({from:announcer,gas:3000000});


    }

    async checkPhase(index){
        let res=this.contract.methods.checkPhase(index).call().then((val)=>{
            console.log("The current phase is -----------------"+val)
        });
        return res;        
    }

     async getDesigne(index){
        let res=this.contract.methods.getDesigne(index).call().then((designe)=>{
            console.log("Design info:----------"+designe)
        });
        return res;
     }

     async getNumDesignes(){
         this.contract.methods.getNumDesignes().call().then((res)=>{
             console.log("Number of designes:------------ "+res)});
         
     }

     async getPlayerInfo(address){
        let res= this.contract.methods.getPlayerDetails(address).call().then((info)=>{
            console.log(info);
        });
        return res;
    }
    async getNumPlayers(){
        let res=this.contract.methods.getNumPlayers().call();
        return res;
    }
    async calculateResult(){
        this.contract.methods.calculateResultPhase1.send({from:user,gas:3000000}).then((val)=>{
            console.log(val);
        });
    }
    async isPlayer(){
        let res=this.contract.methods.getPlayer().call().then((isplayer)=>{
            console.log(isplayer);
        })
        return res
    }

    getAccounts(){

        let val= this.web3.eth.getAccounts();
        return val;
    }
    prova(val){
        for(const ac of val)
        console.log(ac);
    }

    
}



//sequentially select the sm_contract function to call and comment the other
//and re-run the script following this step
const main = async function(){
    const start=new blockchain()
    let accounts=await start.getAccounts();
    let votingAccounts=[accounts[3],accounts[4],accounts[5]];
    console.log("Contract Address------------"+start.ContractAddress)
    await start.announce(accounts[1]);
    await start.voting(votingAccounts,0,1);
    await start.calculateResult(accounts[1],0);

    
   




}

main();
