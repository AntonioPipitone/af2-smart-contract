//!use incluse if it is a module
var Web3 = require('web3');
var fs = require('fs');
var path = require('path')
//!Create the provider 
var provider = 'HTTP://127.0.0.1:8545';
var web3Provider = new Web3.providers.HttpProvider(provider);
var web3 = new Web3(web3Provider);
var utils = web3.utils
//!Contracts
var pathABI= "../ABIs/Scheduling.json";
var ABIContract = JSON.parse(fs.readFileSync(path.resolve(__dirname, pathABI)));
var ABIScheduling = ABIContract.abi;
//*Prendi automaticamente l'ultimo address del contratto - SERVE SOLO NEI TEST
var ContractNetworks = ABIContract.networks
var ContractAddress = ContractNetworks[Object.keys(ContractNetworks)[Object.keys(ContractNetworks).length - 1]].address
console.log("Indirizzo Contratto ----- "+ ContractAddress)
//*Stampalo per check
var Scheduling = new web3.eth.Contract(ABIScheduling, ContractAddress);



async function getAccounts(){
    return await web3.eth.getAccounts()
}

function formatPlayer(account){
    return {
        username : utils.hexToString(account.username),
        position : utils.hexToString(account.position),
        playerType : account.playerType,
        reputation : account.reputation,
        weight : account.weight
    }
}

function ArrToObj(arr){
    if (arr == undefined) return undefined
    newObj = {}
    for(let k of Object.keys(arr)){
        if(isNaN(k)) newObj[k]=arr[k]
    }
    return newObj
}

async function registerUsers(debug){
    for (let [i,account] of accounts.entries()){
        //Registrare un Caller
        if(i==0 || i==1){
            await Scheduling.methods.addCaller(
                utils.asciiToHex("prova"),       // Username
                utils.asciiToHex("prova1"),      // Posizione PROVVISORIAMENTE IN BYTES
            ).send({from:account, gas: 6721975}) //Non inserire i gas nel frontend(Se ne occupa metamask). - Sì nel mobile
            continue
        }
        //Registrare un Maker
        await Scheduling.methods.addMaker(
            utils.asciiToHex("prova"),          // Username 
            utils.asciiToHex("prova1"),         // Posizione PROVVISORIAMENTE IN BYTES
            15,                                 //Disponibilità oraria From
            19,                                 //Disponibilità oraria TO
        ).send({from:account, gas: 6721975})
        
    }

    nPlayer = await Scheduling.methods.getNPlayers().call()
    nMaker = await Scheduling.methods.getNMakers().call()
    nCaller = await Scheduling.methods.getNCallers().call()
    
    console.log("--------------Registrazione----------------")
    console.error("Il numero di giocatori inseriti è 10? ", nPlayer==accounts.length)
    console.error("Il numero di Maker è 8? ", nMaker == 8)
    console.error("Il numero di Caller è 2? ", nCaller == 2)
    console.log("############################################\n\n")
    
    if(debug){
        let accountData = await Scheduling.methods.getPlayers().call()
        /*for (let account of accountData){
            console.table(formatPlayer(account))
        }*/
        for (let account of accounts){
            let data = await Scheduling.methods.getPlayerInfo().call({from:account})
            let airP = ArrToObj(data.airPlayer)
            if(airP.playerType==0) airP["makersInfo"] = ArrToObj(data.airMaker)
            console.table(airP)
        }
    }

}

async function registerPrinter(printerXuser, debug){
    Nprinter = 0
    for (let [i,account] of accounts.entries()){
        if (i==0 || i==1) continue;
        for(let j=0; j<printerXuser; j++){
            //!Add the printer address to the Json in order to rememeber which user has the printer for future test
            printerAddress = web3.eth.accounts.create().address,
            printers[account].push(printerAddress)
            
            await Scheduling.methods.addPrinter(
                printerAddress,                     //Indirizzo Stampante
                utils.asciiToHex("Stampante"),      //Nome
                [0,1],                              //Array of supportedMaterial - 1= 2= 3=
                [0,1,2],                            //Array of supportedNozzles
                2,                                  //Nozzle mounted 
                100,                                //Max print temperature
                100,                                //Max bed temperature
                40,                                 //Volume L
                false,                              //soluble
                true                                //food safety
            ).send({from:account, gas: 6721975}) //Non inserire i gas nell frontend ma sì nel mobile
        }
        Nprinter+= Number(await Scheduling.methods.getMakerNPrinters().call({from:account}))
    }

    console.log("--------------On Boarding----------------")
    console.error(`Il numero di printer inserite è ${printerXuser*8}? `, printerXuser*8==Nprinter)
    if (printerXuser*8!=Nprinter) console.log(Nprinter);
    console.log("############################################\n\n")
    
    if (debug){
        for (let [i,account] of accounts.entries()){
            if (i==0 || i==1) continue;
            data =await Scheduling.methods.getMakerPrinters().call({from:account})
            for(let d of data) console.log(ArrToObj(d));
            console.log("----------------------------------")
        }
    }

}

/*//!Colori
        enum MaterialColor {
            0 - NONE,      
            1 - BLACK,      
            2 - WHITE, 
            3 - BROWN, 
            4 - GRAY, 
            5 - YELLOW, 
            6 - ORANGE, 
            7 - RED, 
            8 - PINK,
            9 - PURPLE, 
            10 - BLU, 
            11 - GREEN     
        }
    */
async function addMaterials(debug){
    let testAccount = accounts[3]
    //Adding 3 Material
    await Scheduling.methods.addMaterials(
        utils.asciiToHex("ciaone"),     //Nome
        1,                              //Tipo di materiale | 0 - ABS , 1 - PLA, 2 - PETG
        1,                              //Colore
        5,                              //Quantità KG
        100,                            //Quantità M
        100,                            //Printer temp
        100,                            //Printer bed
    ).send({from:testAccount, gas: 6721975})
    await Scheduling.methods.addMaterials(
        utils.asciiToHex("ciaone1"),
        2,
        4, 
        5, 
        100, 
        100, 
        100,
    ).send({from:testAccount, gas: 6721975})
    await Scheduling.methods.addMaterials(
        utils.asciiToHex("ciaone2"),
        0,
        2, 
        5, 
        10, 
        100, 
        100,
    ).send({from:testAccount, gas: 6721975})

    materials = await Scheduling.methods.getMaterials().call({from:testAccount})

    console.log("--------------Materials----------------")
    console.log("Test 1 - Adding 3 Materials--------------")
    console.error("Il numero di materiali inseriti è 3? ", materials.length==3 )
    console.log(".......................................")    

    //!Update a material
    await Scheduling.methods.updateMaterial( //!Stessi parametri dell'add
        utils.asciiToHex("ciaone2"),    
        0,
        2, 
        5, 
        10, 
        99, 
        99,
    ).send({from:testAccount, gas: 6721975})

    updatedMaterials = await Scheduling.methods.getMaterials().call({from:testAccount})
    console.log("Test 2 - Update material--------------")
    console.error("Il terzo materiale inserito è stato aggiornato? ", String(materials[0])!=String(updatedMaterials[0]) && String(materials[1])==String(updatedMaterials[1]) && String(materials[2])==String(updatedMaterials[2]))
    console.log(".......................................") 


    await Scheduling.methods.removeMaterial(utils.asciiToHex("ciaone2"), 0).send({from:testAccount, gas: 6721975})
    materialsDelete = await Scheduling.methods.getMaterials().call({from:testAccount})
    //GET ONLY VALID MATERIAL
    let materialsAfterDelete = []
    for(let data of materialsDelete){
        if (data.color != 0){
            materialsAfterDelete.push(data)
        }
    }

    console.log("Test 3 - Delete Material 3-------------")
    console.error("Il numero di materiali è diverso?  ", materials.length!=materialsAfterDelete.length)
    console.log(".......................................") 

    await Scheduling.methods.mountMaterial(utils.asciiToHex("ciaone1"), 2, printers[testAccount][0]).send({from:testAccount, gas: 6721975})
    data =await Scheduling.methods.getMakerPrinters().call({from:testAccount})
    mounted = false
    for(let d of data){
        if (String(d.mountedMaterial)==String(materials[2])){
            mounted = true
        }
    }

    console.log("Test 4 - Mount Material 2-------------")
    console.error("Il materiale è stato montato?  ", mounted)
    console.log(".......................................") 


    await Scheduling.methods.removeMaterial(utils.asciiToHex("ciaone1"), 2).send({from:testAccount, gas: 6721975})
    data =await Scheduling.methods.getMakerPrinters().call({from:testAccount})
    mounted = false
    for(let d of data){
        if (String(d.mountedMaterial)==String(materials[2])){
            mounted = true
        }
    }

    console.log("Test 5 - Delete Mounted Material -------------")
    console.error("Il materiale montato è stato eliminato?  ", !mounted)
    console.log(".......................................") 


    if(debug){
        console.log("Materiali inseriti")
        console.table(ArrToObj(materials[0]))
        console.log("Materiali aggiornati")
        console.table(ArrToObj(updatedMaterials[0]))
        console.log("Eliminazione di un materiale")
        console.log(materialsAfterDelete)
    }  


} 


async function main(){
    accounts = await getAccounts()
    printers = {}
    for (let account of accounts){
        printers[account] = new Array()
    }

    await registerUsers(false)
    await registerPrinter(2,false)
    await addMaterials(false)

}

main()