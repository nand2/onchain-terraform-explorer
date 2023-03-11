// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "hardhat/console.sol";
import "./libs/ToString.sol";
import "./interfaces/ITerraforms.sol";
import "./interfaces/ITerraformsData.sol";
import "./interfaces/ITerraformsDataInterfaces.sol";

import {IScriptyBuilder, WrappedScriptRequest} from "./interfaces/IScriptyBuilder.sol";


contract TerraformNavigator {

    string linksNetwork;

    address immutable terraformsAddress;
    address immutable terraformsDataAddress;
    address immutable terraformsCharactersAddress;

    address immutable scriptyBuilderAddress;
    address immutable ethfsFileStorageAddress;

    mapping(ITerraforms.Status => string) statusToLabel;

    constructor(
        string memory _linksNetwork,
        address _terraformsAddress,
        address _terraformsDataAddress,
        address _terraformsCharactersAddress,
        address _scriptyBuilderAddress, 
        address _ethfsFileStorageAddress) {
        linksNetwork = _linksNetwork;

        terraformsAddress = _terraformsAddress;
        terraformsDataAddress = _terraformsDataAddress;
        terraformsCharactersAddress = _terraformsCharactersAddress;

        scriptyBuilderAddress = _scriptyBuilderAddress;
        ethfsFileStorageAddress = _ethfsFileStorageAddress;

        statusToLabel[ITerraforms.Status.Terrain] = "Terrain";
        statusToLabel[ITerraforms.Status.Daydream] = "Daydream";
        statusToLabel[ITerraforms.Status.Terraformed] = "Terraformed";
        statusToLabel[ITerraforms.Status.OriginDaydream] = "Origin Daydream";
        statusToLabel[ITerraforms.Status.OriginTerraformed] = "Origin Terraformed";
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
            '.site-title a{'
                'text-decoration: none;'
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
                    '<a href="/viewHTML?tokenId:uint256=', ToString.toString(tokenId), '">'
                        '<img src="evm://', linksNetwork, '@0x', ToString.addressToString(terraformsAddress) , '/tokenSVG?tokenId:uint256=', ToString.toString(tokenId), '">'
                    '</a>'
                    '<div class="detail">'
                        '<a href="/viewHTML?tokenId:uint256=', ToString.toString(tokenId), '">',
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
            '<h4 class="site-title">'
                '<a href="/indexHTML?page:uint256=1">'
                    'Terraform navigator'
                '</a>'
            '</h4>'
            '<div class="items">',
            page,
            '</div>'
            '<div class="center">'
        ));

        if(pageNumber > 1) {
            page = string(abi.encodePacked(
                page,
                '<a href="/indexHTML?page:uint256=', ToString.toString(int(pageNumber - 1)), '">'
                '[< prev]'
                '</a>'
            ));
        }
        if(pageNumber < pagesCount) {
            page = string(abi.encodePacked(
                page,
                '<a href="/indexHTML?page:uint256=', ToString.toString(int(pageNumber + 1)), '">'
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


        bytes memory html = IScriptyBuilder(scriptyBuilderAddress)
            .getHTMLWrapped(requests, IScriptyBuilder(scriptyBuilderAddress).getBufferSizeForHTMLWrapped(requests));

        return string(html);
    }

    // function thumbnailSVG(uint256 tokenId) public view returns (string memory) {

    //     string svg = ITerraforms(terraformsSVGAddress).tokenSVG(tokenId);

    // }

    function viewHTML(uint256 tokenId) public view returns (string memory) {
        // Main token data
        ITerraforms.TokenData memory tokenData = ITerraforms(terraformsAddress).tokenSupplementalData(tokenId);
        // Biome
        (string[9] memory charsSet, uint font,, uint biomeIndex) = ITerraformsData(terraformsDataAddress).characterSet(ITerraforms(terraformsAddress).tokenToPlacement(tokenId), ITerraforms(terraformsAddress).seed());
        


        WrappedScriptRequest[] memory requests = new WrappedScriptRequest[](3);

        requests[0].wrapType = 4; // [wrapPrefix][script][wrapSuffix]
        requests[0].wrapPrefix = '<link rel="stylesheet" href="data:text/css;base64,';
        requests[0].name = "simple-2.1.1-06b44bd.min.css";
        requests[0].contractAddress = ethfsFileStorageAddress;
        requests[0].wrapSuffix = '" />';

        requests[1].wrapType = 4; // [wrapPrefix][script][wrapSuffix]
        requests[1].wrapPrefix = "<style>";
        requests[1].scriptContent = abi.encodePacked(
            'body{'
                'grid-template-columns: 1fr min(80rem,90%) 1fr'
            '}'
            '.site-title a{'
                'text-decoration: none;'
            '}'
            '.grid{'
                'display: grid; gap: 2rem; grid-template-columns: 1fr 1fr; grid-auto-rows: min-content;'
            '}'
            '@media (max-width: 768px){'
                '.grid{'
                    'grid-template-columns: 1fr;'
                '}'
            '}'
            '.attrs{'
                'display: grid; gap: 1rem; grid-auto-rows: min-content;'
            '}'
            '.attrs strong{'
                'display: block;'
            '}'
            '.attrs1{'
                'grid-template-columns: repeat(4, 1fr); margin-bottom: 15px'
            '}'
            '.attrs2{'
                'grid-template-columns: repeat(3, 1fr); margin-bottom: 15px'
            '}'
            '.attrs3{'
                'grid-template-columns: repeat(9, 1fr)'
            '}'
            '@font-face {'
                'font-family:"MathcastlesRemix-Regular";'
                'font-display:block;'
                'src:url(data:application/font-woff2;charset=utf-8;base64,', ITerraformsCharacters(terraformsCharactersAddress).font(font), ') format("woff");'
            '}'
            '.chars-set {'
                'font-family: "MathcastlesRemix-Regular"'
            '}'
            );
        requests[1].wrapSuffix = "</style>";

        // Splitting due to stack too deeeep
        bytes memory page;
        {
            // Mode/status
            ITerraforms.Status tokenStatus = ITerraforms(terraformsAddress).tokenToStatus(tokenId);

            page = abi.encodePacked(
                '<div class="attrs attrs1">'
                    '<div>'
                        '<strong>Mode</strong>'
                        '<span>', statusToLabel[tokenStatus], '</span>'
                    '</div>'
                    '<div>'
                        '<strong>Level</strong>'
                        '<span>', ToString.toString(tokenData.level), '</span>'
                    '</div>'
                    '<div>'
                        '<strong>Zone</strong>'
                        '<span>', tokenData.zoneName, '</span>'
                    '</div>'
                    '<div>'
                        '<strong>Biome</strong>'
                        '<span>', ToString.toString(biomeIndex), '</span>'
                    '</div>'
                '</div>'
            );
        }
        {
            // Resource ???
            uint resourceLevel = ITerraformsData(terraformsDataAddress).resourceLevel(ITerraforms(terraformsAddress).tokenToPlacement(tokenId), ITerraforms(terraformsAddress).seed());

            page = abi.encodePacked(
                page,
                '<div class="attrs attrs2">'
                    '<div>'
                        '<strong>X</strong>'
                        '<span>', ToString.toString(tokenData.xCoordinate), '</span>'
                    '</div>'
                    '<div>'
                        '<strong>Y</strong>'
                        '<span>', ToString.toString(tokenData.yCoordinate), '</span>'
                    '</div>'
                    '<div>'
                        '<strong>???</strong>'
                        '<span>', ToString.toString(resourceLevel), '</span>'
                    '</div>'
                '</div>'
            );
        }
        {
            bytes memory charsSetSection;
            for(uint i = 0; i < charsSet.length; i++) {
                charsSetSection = abi.encodePacked(
                    charsSetSection,
                    '<div>'
                        '<div class="chars-set">', charsSet[i], '</div>'
                        '<span>', ToString.toString(i), '</span>'
                    '</div>'
                );
            }

            page = abi.encodePacked(
                page,
                '<div>'
                    '<strong>Character set</strong>'
                '</div>'
                '<div class="attrs attrs3">',
                    charsSetSection,
                '</div>'
            );
        }
        page = abi.encodePacked(
            '<h4 class="site-title">'
                '<a href="/indexHTML?page:uint256=1">'
                    'Terraform navigator'
                '</a>'
            '</h4>'
            '<div class="grid">'
                '<div>'
                    '<img src="evm://', linksNetwork, '@0x', ToString.addressToString(terraformsAddress) , '/tokenSVG?tokenId:uint256=', ToString.toString(tokenId) ,'">'
                '</div>'
                '<div>'
                    '<div style="margin-bottom: 20px">'
                        '<div>Parcel</div>'
                        '<div style="font-size: 1.7rem; font-weight: bold;">', ToString.toString(tokenId), '</div>'
                    '</div>',
                page,
                '</div>'
            '</div>'         
        );

        requests[2].wrapType = 4; // [wrapPrefix][script][wrapSuffix]
        requests[2].scriptContent = page;


        bytes memory html = IScriptyBuilder(scriptyBuilderAddress)
            .getHTMLWrapped(requests, IScriptyBuilder(scriptyBuilderAddress).getBufferSizeForHTMLWrapped(requests));

        return string(html);
    }

}