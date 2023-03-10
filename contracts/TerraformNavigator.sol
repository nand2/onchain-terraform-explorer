// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "hardhat/console.sol";
import "./libs/ToString.sol";
import "./interfaces/ITerraforms.sol";
import "./interfaces/ITerraformsData.sol";
import "./interfaces/ITerraformsDataInterfaces.sol";

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

    function indexHTML(uint pageNumber) public view returns (string memory) {

        uint terraformsTotalSupply = ITerraforms(terraformsAddress).totalSupply();
        uint terraformsPerPage = 10;
        uint pagesCount = terraformsTotalSupply / terraformsPerPage + (terraformsTotalSupply % terraformsPerPage > 0 ? 1 : 0);

        WrappedScriptRequest[] memory requests = new WrappedScriptRequest[](3);

        requests[0].wrapType = 4; // [wrapPrefix][script][wrapSuffix]
        requests[0].wrapPrefix = '<link rel="stylesheet" href="data:text/css;base64,';
        requests[0].name = "simple-2.1.1-06b44bd.min.css";
        requests[0].contractAddress = ethfsFileStorageAddress;
        requests[0].wrapSuffix = '" />';

        requests[1].wrapType = 4; // [wrapPrefix][script][wrapSuffix]
        requests[1].wrapPrefix = "<style>";
        requests[1].scriptContent = 
            'body{'
                'grid-template-columns: 1fr min(80rem,90%) 1fr'
            '}'
            '.items{'
                'display:grid; gap: 2rem; grid-template-columns: repeat(5, 1fr); grid-auto-rows: min-content;'
            '}'
            '@media (max-width: 1024px){'
                '.items{'
                    'grid-template-columns: repeat(3, 1fr);'
                '}'
            '}'
            '@media (max-width: 768px){'
                '.items{'
                    'grid-template-columns: repeat(2, 1fr);'
                '}'
            '}'
            '.item{'
                'text-align: center; margin-bottom: 10px'
            '}'
            '.item img{'
                'display: block; margin-bottom: 6px'
            '}'
            '.item .detail{'
                'line-height: 1.3'
            '}'
            '.center{'
                'text-align: center'
            '}';
        requests[1].wrapSuffix = "</style>";

        string memory page;
        for(uint tokenId = (pageNumber - 1) * terraformsPerPage + 1; tokenId <= pageNumber * terraformsPerPage && tokenId <= terraformsTotalSupply; tokenId++) {

            ITerraforms.TokenData memory tokenData = ITerraforms(terraformsAddress).tokenSupplementalData(tokenId);
            (,,, uint biomeIndex) = ITerraformsData(terraformsDataAddress).characterSet(ITerraforms(terraformsAddress).tokenToPlacement(tokenId), ITerraforms(terraformsAddress).seed());

            page = string(abi.encodePacked(
                page,
                '<div class="item">'
                    '<a href="evm://0x', ToString.addressToString(address(this)), '/viewHTML?tokenId:uint256=', ToString.toString(tokenId), '">'
                        '<img src="evm://0x', ToString.addressToString(terraformsAddress) , '/tokenSVG?tokenId:uint256=', ToString.toString(tokenId), '">'
                    '</a>'
                    '<div class="detail">'
                        '<a href="evm://0x', ToString.addressToString(address(this)), '/viewHTML?tokenId:uint256=', ToString.toString(tokenId), '">',
                            ToString.toString(tokenId),
                        '</a>'
                    '</div>'
                    '<div class="detail">'
                        'L', ToString.toString(tokenData.level), '/B', ToString.toString(biomeIndex), '/', tokenData.zoneName,
                    '</div>'
                '</div>'
            ));
        }

        page = string(abi.encodePacked(
            '<h3>Terraform navigator</h1>'
            '<div class="items">',
            page,
            '</div>'
            '<div class="center">'
        ));

        if(pageNumber > 1) {
            page = string(abi.encodePacked(
                page,
                '<a href="evm://0x', ToString.addressToString(address(this)), '/indexHTML?page:uint256=', ToString.toString(int(pageNumber - 1)), '">'
                '[< prev]'
                '</a>'
            ));
        }
        if(pageNumber < pagesCount) {
            page = string(abi.encodePacked(
                page,
                '<a href="evm://0x', ToString.addressToString(address(this)), '/indexHTML?page:uint256=', ToString.toString(int(pageNumber + 1)), '">'
                '[next >]'
                '</a>'
            ));
        }

        page = string(abi.encodePacked(
            page,
            '</div>'
        ));

        requests[2].wrapType = 4; // [wrapPrefix][script][wrapSuffix]
        requests[2].scriptContent = bytes(page);


        // Random buffer for now
//TODO
        uint bufferSize = 291925;

        bytes memory html = IScriptyBuilder(scriptyBuilderAddress)
            .getHTMLWrapped(requests, bufferSize);

        return string(html);
    }

    // function thumbnailSVG(uint256 tokenId) public view returns (string memory) {

    //     string svg = ITerraforms(terraformsSVGAddress).tokenSVG(tokenId);

    // }

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
            '<img src="evm://0x', ToString.addressToString(terraformsAddress) , '/tokenSVG?tokenId:uint256=', ToString.toString(tokenId) ,'">'
        );

        // Random buffer for now
        uint bufferSize = 291925;

        bytes memory html = IScriptyBuilder(scriptyBuilderAddress)
            .getHTMLWrapped(requests, bufferSize);

        return string(html);
    }

}