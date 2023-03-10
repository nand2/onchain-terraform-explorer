// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "hardhat/console.sol";
import "./libs/ToString.sol";

import {IScriptyBuilder, WrappedScriptRequest} from "./interfaces/IScriptyBuilder.sol";


contract TerraformNavigator {

    address public immutable terraformsAddress;
    address public immutable terraformsDataAddress;
    address public immutable scriptyStorageAddress;
    address public immutable scriptyBuilderAddress;
    address public immutable ethfsFileStorageAddress;

    constructor(
        address _terraformsAddress,
        address _terraformsDataAddress,
        address _scriptyStorageAddress,
        address _scriptyBuilderAddress, 
        address _ethfsFileStorageAddress) {
        terraformsAddress = _terraformsAddress;
        terraformsDataAddress = _terraformsDataAddress;
        scriptyStorageAddress = _scriptyStorageAddress;
        scriptyBuilderAddress = _scriptyBuilderAddress;
        ethfsFileStorageAddress = _ethfsFileStorageAddress;
    }

    function indexHTML() public view returns (string memory) {

        WrappedScriptRequest[] memory requests = new WrappedScriptRequest[](3);
        requests[0].name = "scriptyBase";
        requests[0].wrapType = 0; // <script>[script]</script>
        requests[0].contractAddress = scriptyStorageAddress;

        // requests[1].name = "p5-v1.5.0.min.js.gz";
        // requests[1].wrapType = 2; // <script type="text/javascript+gzip" src="data:text/javascript;base64,[script]"></script>
        // requests[1].contractAddress = ethfsFileStorageAddress;

        // requests[2].name = "gunzipScripts-0.0.1.js";
        // requests[2].wrapType = 1; // <script src="data:text/javascript;base64,[script]"></script>
        // requests[2].contractAddress = ethfsFileStorageAddress;


        // requests[1].wrapType = 0; // <script>[script]</script>
        // requests[1].scriptContent = "xxx";

        requests[1].wrapType = 4; // [wrapPrefix][script][wrapSuffix]
        requests[1].wrapPrefix = "<style>";
        requests[1].scriptContent = 'body {background-color: #171717; color: #f5f5f5}';
        requests[1].wrapSuffix = "</style>";

        requests[2].wrapType = 4; // [wrapPrefix][script][wrapSuffix]
        requests[2].scriptContent = abi.encodePacked(
            '<h1 style="text-align: center">Terraform navigator</h1>'
            '<br />'
            '<a href="evm://0x', ToString.addressToString(address(this)), '/viewHTML?tokenId:uint256=4197">'
                '<img src="evm://0x4e1f41613c9084fdb9e34e11fae9412427480e56/tokenSVG?tokenId:uint256=4197" style="width:200px">'
            '</a>'
            '<a href="evm://0x', ToString.addressToString(address(this)), '/viewHTML?tokenId:uint256=4198">'
                '<img src="evm://0x4e1f41613c9084fdb9e34e11fae9412427480e56/tokenSVG?tokenId:uint256=4198" style="width:200px">'
            '</a>'
            '<a href="evm://0x', ToString.addressToString(address(this)), '/viewHTML?tokenId:uint256=4199">'
                '<img src="evm://0x4e1f41613c9084fdb9e34e11fae9412427480e56/tokenSVG?tokenId:uint256=4199" style="width:200px">'
            '</a>'
        );

        // Random buffer for now
        uint bufferSize = 291925;

        bytes memory html = IScriptyBuilder(scriptyBuilderAddress)
            .getHTMLWrapped(requests, bufferSize);

        return string(html);
    }

    function viewHTML(uint256 tokenId) public view returns (string memory) {

        WrappedScriptRequest[] memory requests = new WrappedScriptRequest[](3);
        requests[0].name = "scriptyBase";
        requests[0].wrapType = 0; // <script>[script]</script>
        requests[0].contractAddress = scriptyStorageAddress;


        requests[1].wrapType = 4; // [wrapPrefix][script][wrapSuffix]
        requests[1].wrapPrefix = "<style>";
        requests[1].scriptContent = 'body {background-color: #171717; color: #f5f5f5}';
        requests[1].wrapSuffix = "</style>";

        requests[2].wrapType = 4; // [wrapPrefix][script][wrapSuffix]
        requests[2].scriptContent = abi.encodePacked(
            '<h1 style="text-align: center">Terraform ', ToString.toString(tokenId), '</h1>'
            '<br />'
            '<img src="evm://0x4e1f41613c9084fdb9e34e11fae9412427480e56/tokenSVG?tokenId:uint256=', ToString.toString(tokenId) ,'">'
        );

        // Random buffer for now
        uint bufferSize = 291925;

        bytes memory html = IScriptyBuilder(scriptyBuilderAddress)
            .getHTMLWrapped(requests, bufferSize);

        return string(html);
    }

}