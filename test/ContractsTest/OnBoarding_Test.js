import Contract_Test from "./Contract_Test.js"



export default class OnBoarding_Test extends Contract_Test{

    constructor(provider, debug){
        super("OnBoarding",provider, debug)
        this.printers = {}
    }

    async runTest(debug){
        await this.registerPrinter(2,debug)
        await this.materialsTest(debug)
    }


    async registerPrinter(printerXuser, debug){
        let accounts = await this.provider.getAccounts()
        for (let account of accounts){
            this.printers[account] = new Array()
        } 

        let Nprinter = 0
        for (let [i,account] of accounts.entries()){
            if (i==0 || i==1) continue;
            for(let j=0; j<printerXuser; j++){
                //!Add the printer address to the Json in order to rememeber which user has the printer for future test
                let printerAddress = this.web3.eth.accounts.create().address
                this.printers[account].push(printerAddress)
                await this.contract.methods.addPrinter(
                    printerAddress,                     //Indirizzo Stampante
                    this.utils.asciiToHex("Stampante"),      //Nome
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
            Nprinter+= Number(await this.contract.methods.getMakerNPrinters().call({from:account}))
        }

        console.log("--------------On Boarding----------------")
        console.error(`Il numero di printer inserite è ${printerXuser*8}? `, printerXuser*8==Nprinter)
        if (printerXuser*8!=Nprinter) console.log(Nprinter);
        console.log("############################################\n\n")
        
        if (debug){
            for (let [i,account] of accounts.entries()){
                if (i==0 || i==1) continue;
                data =await this.contract.methods.getMakerPrinters().call({from:account})
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
    async materialsTest(debug){
        let accounts = await this.provider.getAccounts()
        let testAccount = accounts[3]
        //Adding 3 Material
        await this.contract.methods.addMaterials(
            this.utils.asciiToHex("ciaone"),     //Nome
            1,                              //Tipo di materiale | 0 - ABS , 1 - PLA, 2 - PETG
            1,                              //Colore
            5,                              //Quantità KG
            100,                            //Quantità M
            100,                            //Printer temp
            100,                            //Printer bed
        ).send({from:testAccount, gas: 6721975})
        await this.contract.methods.addMaterials(
            this.utils.asciiToHex("ciaone1"),
            2,
            4, 
            5, 
            100, 
            100, 
            100,
        ).send({from:testAccount, gas: 6721975})
        await this.contract.methods.addMaterials(
            this.utils.asciiToHex("ciaone2"),
            0,
            2, 
            5, 
            10, 
            100, 
            100,
        ).send({from:testAccount, gas: 6721975})

        let materials = await this.contract.methods.getMaterials().call({from:testAccount})

        console.log("--------------Materials----------------")
        console.log("Test 1 - Adding 3 Materials--------------")
        console.error("Il numero di materiali inseriti è 3? ", materials.length==3 )
        console.log(".......................................")    

        //!Update a material
        await this.contract.methods.updateMaterial( //!Stessi parametri dell'add
            this.utils.asciiToHex("ciaone2"),    
            0,
            2, 
            5, 
            10, 
            99, 
            99,
        ).send({from:testAccount, gas: 6721975})

        let updatedMaterials = await this.contract.methods.getMaterials().call({from:testAccount})
        console.log("Test 2 - Update material--------------")
        console.error("Il terzo materiale inserito è stato aggiornato? ", String(materials[0])!=String(updatedMaterials[0]) && String(materials[1])==String(updatedMaterials[1]) && String(materials[2])==String(updatedMaterials[2]))
        console.log(".......................................") 


        await this.contract.methods.removeMaterial(this.utils.asciiToHex("ciaone2"), 0).send({from:testAccount, gas: 6721975})
        let materialsDelete = await this.contract.methods.getMaterials().call({from:testAccount})
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

        await this.contract.methods.mountMaterial(this.utils.asciiToHex("ciaone1"), 2, this.printers[testAccount][0]).send({from:testAccount, gas: 6721975})
        let data =await this.contract.methods.getMakerPrinters().call({from:testAccount})
        let mounted = false
        for(let d of data){
            if (String(d.mountedMaterial)==String(materials[2])){
                mounted = true
            }
        }

        console.log("Test 4 - Mount Material 2-------------")
        console.error("Il materiale è stato montato?  ", mounted)
        console.log(".......................................") 


        await this.contract.methods.removeMaterial(this.utils.asciiToHex("ciaone1"), 2).send({from:testAccount, gas: 6721975})
        data =await this.contract.methods.getMakerPrinters().call({from:testAccount})
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

}
