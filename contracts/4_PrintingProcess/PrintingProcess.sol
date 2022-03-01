pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

contract PrintingProcess{


    //information about the print begin,the print end and design name
    struct printingProcess{
        bytes32 designHash;
        uint256 piece;
        uint256 startTimestamp;
        uint256 endTimestamp;
        int status;
    }
    
    //Printer details indexed by printer address
    //mapping (address => printerDetails) private printers;
    //mapping (address => uint) private isPrinter;
    //address[] private printerAddresses;

    //Makers orders
            //orderID   //printerAddress
    mapping (bytes32 => mapping(address => printingProcess[])) orderProcess;

    function get_printing_process(bytes32 orderID ,address _printerAddress)
    public view 
    returns(printingProcess[] memory){
        return orderProcess[orderID][_printerAddress];
    }

    function start_printing(bytes32 orderID ,address _printerAddress, bytes32 designHash, uint256 piece, uint256 startTimestamp) 
    public payable{
        //require( isPlayer [ msg.sender ] == 1, "Only registered player can add proof of printer.");
        //Check for an existing printer
        //require( isPrinter [ _printerAddress ] == 1, "Only proof from a registered printer can be added.");
        require(this.search_printing_process(orderID, _printerAddress, piece)==-1, "There is already a proof of print for this piece");
        orderProcess[orderID][_printerAddress].push(printingProcess(designHash, piece, startTimestamp, 0, -1));
    }

    function search_printing_process(bytes32 orderID, address _printerAddress, uint256 piece) 
    public view  
    returns(int index){
        index = -1;
        for(uint i = 0; i<orderProcess[orderID][_printerAddress].length; i++){
            if (orderProcess[orderID][_printerAddress][i].piece==piece){
                index = int256(i);
                return index;
            }
        }
    }

    function end_printing(bytes32 orderID ,address _printerAddress, uint256 piece, uint256 endTimestamp, int status) 
    public payable{

        //require( isPlayer [ msg.sender ] == 1, "Only registered player can add proof of printer.");
        //Check for an existing printer
        //require( isPrinter [ _printerAddress ] == 1, "Only proof from a registered printer can be added.");
        require(status!=0 && status<=2, "status not valid");
        
        int index = this.search_printing_process(orderID, _printerAddress, piece);
        require(index!=-1, "You can't end a proof of print before starts it");
        
        uint256 i = uint256(index);
        require(endTimestamp>orderProcess[orderID][_printerAddress][i].startTimestamp,"End timestamp cannot be before start timestamp");
        require(orderProcess[orderID][_printerAddress][i].status!=2, "This proof of print already finished with success");
        
        orderProcess[orderID][_printerAddress][i].endTimestamp=endTimestamp;
        orderProcess[orderID][_printerAddress][i].status=status;
    }



} 
