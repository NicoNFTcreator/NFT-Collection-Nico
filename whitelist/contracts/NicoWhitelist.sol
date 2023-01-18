//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/**
 * @author : https://github.com/quentin-abei
 */
contract NicoWhitelist {
    
    error AlreadyWhitelisted(address sender);
    error WhitelistSpotsSoldOut(uint16 maxNumberReached);
    // @dev set the Max number of whitelisted addresses allowed
    //it can be any number in uint16 range you want
    uint16 public maxWhitelistedAddresses;

    // @dev Create a mapping of whitelistedAddresses
    // if an address is whitelisted, we would set it to true, it is false by default for all other addresses.
    mapping(address => bool) public whitelistedAddresses;

    // @dev numAddressesWhitelisted would be used to keep track of how many addresses have been whitelisted
    uint16 public numAddressesWhitelisted;

    // @dev Set the Max number of whitelisted addresses
    // User will put the value at the time of deployment
    constructor(uint16 _maxWhitelistedAddresses) {
        maxWhitelistedAddresses =  _maxWhitelistedAddresses;
    }

    /**
        addAddressToWhitelist - This function adds the address of the sender to the
        whitelist
     */
    function addAddressToWhitelist() public {
        if(whitelistedAddresses[msg.sender]){
            revert AlreadyWhitelisted(msg.sender);
        }
        if(numAddressesWhitelisted == maxWhitelistedAddresses) {
            revert WhitelistSpotsSoldOut(maxWhitelistedAddresses);
        }
        whitelistedAddresses[msg.sender] = true;
        numAddressesWhitelisted += 1;
    }

}