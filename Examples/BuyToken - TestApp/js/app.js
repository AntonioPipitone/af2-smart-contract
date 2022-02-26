App = {
    web3Provider: null,
    contracts: {},
    account: '0x0',
    loading: false,
    tokenPrice: 1000000000000000,
    tokensSold: 0,
    tokensAvailable: 750000,

    init: function() {
        console.log("App initialized ... ")
        return App.initWeb3();
    },

    initWeb3: function() {
        if (typeof web3 !== 'undefined') {
            // If a web3 instance is already provided by Meta Mask.
            App.web3Provider = web3.currentProvider;
            web3 = new Web3(web3.currentProvider);
        } else {
            // Specify default instance if no web3 instance provided
            App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
            web3 = new Web3(App.web3Provider);
        }
        return App.initContracts();
    },

    initContracts: function() {
        $.getJSON("AntoTokenSale.json", function(antoTokenSale){
            App.contracts.AntoTokenSale = TruffleContract(antoTokenSale);
            App.contracts.AntoTokenSale.setProvider(App.web3Provider);
            App.contracts.AntoTokenSale.deployed().then(function(antoTokenSale) {
                console.log("Anto Token Sale Address:", antoTokenSale.address);
            });
            }).done(function(){
                $.getJSON("TestToken.json", function(testToken){
                    App.contracts.TestToken = TruffleContract(testToken);
                    App.contracts.TestToken.setProvider(App.web3Provider);
                    App.contracts.TestToken.deployed().then(function(testToken) {
                        console.log("Test Token Address:", testToken.address);
                    });
                    App.listenForEvents();
                    return App.render();
            });
        })
    },

    listenForEvents: function(){
        App.contracts.AntoTokenSale.deployed().then(function(instance){
            instance.Sell({}, {
                fromBlock: 0,
                toBlock: 'latest',
            }).watch(function(error,event){
                console.log("event triggered", event);
                App.render();
            })
        })
    },

    render: function() {
        if(App.loading){
            return;
        }
        App.loading = true;
        var loader = $('#loader');
        var content = $('#content');

        loader.show();
        content.hide();

        web3.eth.getCoinbase(function(err, account){
            if(err === null) {
                console.log("account", account);
                App.account = account;
                $('#accountAddress').html("Your Account:  " + account);
            }
        })
        //Load token sale contract
            App.contracts.AntoTokenSale.deployed().then(function(instance){
               antoTokenSaleInstance = instance;
               return antoTokenSaleInstance.tokenPrice();
            }).then(function(tokenPrice){
               // console.log("tokenPrice", tokenPrice)
                App.tokenPrice = tokenPrice;
                $('.token-price').html(web3.fromWei(App.tokenPrice, "ether").toString());
                return antoTokenSaleInstance.tokensSold();
            }).then(function(tokensSold){
                App.tokensSold = tokensSold.toString();
                $('.tokens-sold').html(App.tokensSold);
                $('.tokens-available').html(App.tokensAvailable);

                var progressPercent = (Math.ceil(App.tokensSold) / App.tokensAvailable) * 100;
                $('#progress').css('width', progressPercent + '%');

                // Load token contract
                App.contracts.TestToken.deployed().then(function(instance){
                    testTokenInstance = instance;
                    return testTokenInstance.balanceOf(App.account);
                }).then(function(balance){
                    $('.AF2-balance').html(balance.toNumber()/(10**18));
                    App.loading = false;
                    loader.hide();
                    content.show();
                })
            });
         },
    buyTokens: function(){
        $('#content').hide();
        $('#loader').show();
        var numberOfTokens = $('#numberOfTokens').val();
        App.contracts.AntoTokenSale.deployed().then(function(instance){
            return instance.buyTokens(numberOfTokens, {
                from: App.account,
                value: numberOfTokens * App.tokenPrice,
                gas: 500000
            });
        }).then(function(result){
           console.log("tokens bought..")
           $('form').trigger('reset')
           //Wait for Sell event
        });
    }
}

$(function (){
    $(window).load(function(){
        App.init();
    })
});
