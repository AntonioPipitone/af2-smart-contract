const bs58=require('bs58');

class blockchain{
    constructor(){
        this.json=require("./ABIs/designVoting1.json");
        this.Web3 = require('web3');
        this.provider="HTTP://127.0.0.1:7545";
        this.web3Provider=new this.Web3.providers.HttpProvider(this.provider);
        this.web3 = new this.Web3(this.web3Provider);
        this.contract = new this.web3.eth.Contract(this.json['abi'],'0xad2867C0469928739Dea75608839700aDBD6F351');
        this.hash=bs58.decode("QmPZ9gcCEpqKTo6aq61g2nXGUhM4iCL3ewB6LDXZCtioEB").slice(2);
     }

     sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
      }

      callProva(){
          let res=this.contract.methods.prova(this.hash).call();
          return res;
      }

      convertToIpfsHash(val){
            console.log(val);
            val=val.slice(2);
            let buff=Buffer.from(`1220${val}`, "hex");
            console.log(bs58.encode(buff));

      }
      addPlayer(users){

        for(let user of users){
            this.contract.methods.addPlayer().send({from:user,gas:3000000});
        
        }
     }

     announce(user){
         this.contract.methods.announce(this.web3.utils.fromAscii("test1"),Date.now(),this.web3.utils.fromWei('1000000000000000000'),1,1).send({from: user, gas: 3000000, value: this.web3.utils.fromWei('1000000000000000000'),gasPrice:0}).then(res => 
            console.log('Success', res))
      .catch(err => console.log(err));

     }


     register(users,index){
         for(let user of users)
            this.contract.methods.register(index,1).send({from: user, gas: 3000000, value: this.web3.utils.fromWei('1000000000000000000'),gasPrice:0});
     }

    voting(users,index,vote){
        for(let user of users)
            this.contract.methods.vote(index,vote,Date.now()).send({from: user, gas: 3000000, value: 1000000000000000000,gasPrice:0});
        
    }

    checkResult(index){
        let res=this.contract.methods.checkResult(index,Date.now()).call();
        if(res==1)
            console.log("Passed");
        else console.log("Failed");
    }

    calculateResult(announcer,index){
        this.contract.methods.calculateResult(index,Date.now()).send({from:announcer,gas:3000000});


    }

    checkPhase(index){
        let res=this.contract.methods.checkPhase(index).call();
        return res;        
    }

     getDesigne(index){
        let res=this.contract.methods.getDesigne(index).call();
        return res;
     }

     getNumDesignes(){
         let res=this.contract.methods.getNumDesignes().call();
         return res;
     }

     getPlayerInfo(address){
        let res= this.contract.methods.getPlayerDetails(address).call();
        return res;
    }
    getNumPlayers(){
        let res=this.contract.methods.getNumPlayers().call();
        return res;
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
    console.log(accounts);
    //await start.addPlayer(accounts);
    let info=await start.getNumPlayers();
    console.log("Number of player: "+info);
    //await start.announce(accounts[1]);
    let num=await start.getNumDesignes();
    console.log("Number of designes: "+num);
    //await start.register(votingAccounts,0);
    //await start.voting(votingAccounts,0,1);
    //start.sleep(25000);
    await start.calculateResult(accounts[1],0);
    //let prova=await start.checkPhase(0);
    //console.log(prova);

    
   




}

main();
