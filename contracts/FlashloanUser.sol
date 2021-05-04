// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import './IFlashloanUser.sol';
import './FlashloanProvider.sol';

contract FlashloanUser is IFlashloanUser {

    function startFlashloan(
        address flashloan,
        uint _amount, 
        address _token, 
        bytes memory _data
    ) external {
        FlashloanProvider(flashloan).executeFlashloan(address(this), _amount, _token, _data);
    }

    /// @notice required flashloanCallback function that must be implemented by user and called by Provider
    /// @param _amount the amount of tokens to borrow
    /// @param _token the addrress of the token to borrow
    /// @param _data any bytes data to send 
   function flashloanCallback(uint _amount, address _token, bytes memory _data) override external {
       //do some arbitrage, liquidation, etc..

       //Reimburse borrowed tokens
       IERC20(_token).transfer(msg.sender, _amount);
   }
}