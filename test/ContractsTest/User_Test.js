import Contract_Test from "./Contract_Test.js"

export default class User_Test extends Contract_Test{

    constructor(provider, debug){
        super("User",provider,debug)
    }

    async runTest(){
        await this.registerUsers(this.debug);
    }

    async registerUsers(debug){
        let accounts = await this.provider.getAccounts()
        for (let [i,account] of accounts.entries()){
            //Registrare un Caller
            if(i==0 || i==1){
                await this.contract.methods.addCaller(
                    this.utils.asciiToHex("prova"),       // Username
                    this.utils.asciiToHex("prova1"),      // Posizione PROVVISORIAMENTE IN BYTES
                ).send({from:account, gas: 6721975}) //Non inserire i gas nel frontend(Se ne occupa metamask). - Sì nel mobile
                continue
            }
            //Registrare un Maker
            await this.contract.methods.addMaker(
                this.utils.asciiToHex("prova"),          // Username 
                this.utils.asciiToHex("prova1"),         // Posizione PROVVISORIAMENTE IN BYTES
                15,                                 //Disponibilità oraria From
                19,                                 //Disponibilità oraria TO
            ).send({from:account, gas: 6721975})
            
        }
    
        let nPlayer = await this.contract.methods.getNPlayers().call()
        let nMaker = await this.contract.methods.getNMakers().call()
        let nCaller = await this.contract.methods.getNCallers().call()
        
        console.log("--------------Registrazione----------------")
        console.error("Il numero di giocatori inseriti è 10? ", nPlayer==accounts.length)
        console.error("Il numero di Maker è 8? ", nMaker == 8)
        console.error("Il numero di Caller è 2? ", nCaller == 2)
        console.log("############################################\n\n")
        
        if(debug){
            let accountData = await this.contract.methods.getPlayers().call()
            /*for (let account of accountData){
                console.table(formatPlayer(account))
            }*/
            for (let account of accounts){
                let data = await this.contract.methods.getPlayerInfo().call({from:account})
                let airP = ArrToObj(data.airPlayer)
                if(airP.playerType==0) airP["makersInfo"] = ArrToObj(data.airMaker)
                console.table(airP)
            }
        }
    
    }
    
    formatPlayer(account){
        return {
            username : this.utils.hexToString(account.username),
            position : this.utils.hexToString(account.position),
            playerType : account.playerType,
            reputation : account.reputation,
            weight : account.weight
        }
    }
    
}