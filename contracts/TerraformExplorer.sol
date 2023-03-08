// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "hardhat/console.sol";

import {IScriptyBuilder, WrappedScriptRequest} from "./interfaces/IScriptyBuilder.sol";


contract TerraformExplorer {

    address public immutable scriptyStorageAddress;
    address public immutable scriptyBuilderAddress;
    address public immutable ethfsFileStorageAddress;

    constructor(
        address _scriptyStorageAddress,
        address _scriptyBuilderAddress, 
        address _ethfsFileStorageAddress) {
        scriptyStorageAddress = _scriptyStorageAddress;
        scriptyBuilderAddress = _scriptyBuilderAddress;
        ethfsFileStorageAddress = _ethfsFileStorageAddress;
    }

    function indexHTML() public view returns (string memory) {

        WrappedScriptRequest[] memory requests = new WrappedScriptRequest[](2);
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

        requests[1].wrapType = 4; // [wrapPrefix][script][suffix]
        requests[1].scriptContent = '<h1 style="text-align: center">Terraform explorer</h1>';

        // Random buffer for now
        uint bufferSize = 291925;

        bytes memory html = IScriptyBuilder(scriptyBuilderAddress)
            .getHTMLWrapped(requests, bufferSize);

        return string(html);
    }


}