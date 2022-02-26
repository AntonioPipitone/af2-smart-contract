library PrinterDetailsData{
       
    
    
    struct printerDetails
    {
        bytes32 make;
        bytes32 name;
        uint strength;    // values: Very High = 3, High = 2, Medium =1 , Low = 0
        uint flexibility; // values: Very High = 3, High = 2, Medium =1 , Low = 0
        uint durability;  // values: Very High = 3, High = 2, Medium =1 , Low = 0
        uint difficulty;  // values: Very High = 3, High = 2, Medium =1 , Low = 0
        int printTemperature;
        int bedTemperature;
        bool soluble;
        bool foodSafety;
    }
    
        struct printingProcess
    {

        uint256 startTimestamp;
        uint256 endTimestamp;
        bytes32 printingdataHash;
        bytes32 designHash;

    }
    
}
      
