// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import './IFlashloanUser.sol';

contract FlashloanProvider is ReentrancyGuard {

    // keep track of all the tokens that can be lent
    mapping(address => IERC20) public tokens;

    constructor(address[] memory _supportedTokens) {
        // add the supported tokens
        for(uint i=0; i < _supportedTokens.length; i++) {
            tokens[_supportedTokens[i]] = IERC20(_supportedTokens[i]);
        }

    }

    /// @notice function to execute smart contract with Reentrancy protection
    /// @param _callback the address to receive the flashloan 
    /// @param _amountTokens the amount of tokens to borrow
    /// @param _token the addrress of the token to borrow
    /// @param _data data to send with .flashloanCallback()
    function executeFlashloan(
        address _callback, 
        uint _amountTokens,
        address _token,
        bytes memory _data
    ) 
    external 
    nonReentrant()
    {
        // check that token is not zero address
        require(_token != address(0), 'invalid token address');
        IERC20 token = IERC20(_token);
        // check token is supported
        require(tokens[_token] == token);
        // keep track of originalBalance token that must be restored at end
        uint originalBalance = token.balanceOf(address(this));
        // check that amount loan requested is less than or equal available tokens
        require(_amountTokens <= originalBalance);
        // 
        IFlashloanUser(_callback).flashloanCallback(_amountTokens, _token, _data);
        // ensure amounToken is repaid
        require(token.balanceOf(address(this)) == originalBalance, 'flashloan not reimbursed');

    }

}