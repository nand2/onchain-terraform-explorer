// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITerraforms {
    function tokenURI(uint) 
        external 
        view 
        returns (string memory);

    function tokenHTML(uint) 
        external 
        view 
        returns (string memory);

    function tokenSVG(uint) 
        external 
        view 
        returns (string memory);

    function totalSupply()
        external
        view
        returns (uint256);
}