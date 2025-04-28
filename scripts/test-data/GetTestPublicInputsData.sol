pragma solidity ^0.8.17;

import { Script } from "forge-std/Script.sol";
import "forge-std/console.sol";

//import { DataTypeConverter } from "../../contracts/libraries/DataTypeConverter.sol";


contract GetTestPublicInputsData is Script {

    struct PublicInputs {
        bytes32 merkleRoot;
        bytes32 nullifier;
        bytes32 jobTitleCommitment;
        bytes32 skillsCombinedCommitment;
    }

    /**
     * @dev - Get a test input data from the testPublicInputsData.json file
     */
    function getTestPublicInputsData() public returns (PublicInputs memory _publicInputs) {
        /// @dev - Read the output.json file and parse the JSON data
        string memory json = vm.readFile("scripts/test-data/testPublicInputsData.json");
        console.log(json);
        bytes memory data = vm.parseJson(json);
        //console.logBytes(data);

        bytes32 _merkleRoot = vm.parseJsonBytes32(json, ".merkle_root");
        bytes32 _nullifier = vm.parseJsonBytes32(json, ".nullifier");
        bytes32 _jobTitleCommitment = vm.parseJsonBytes32(json, ".job_title_commitment");
        bytes32 _skillsCombinedCommitment = vm.parseJsonBytes32(json, ".skills_combined_commitment");
        console.logBytes32(_merkleRoot);
        console.logBytes32(_nullifier);
        console.logBytes32(_jobTitleCommitment);
        console.logBytes32(_skillsCombinedCommitment);

        PublicInputs memory publicInputs = PublicInputs({
            merkleRoot: _merkleRoot,
            nullifier: _nullifier,
            jobTitleCommitment: _jobTitleCommitment,
            skillsCombinedCommitment: _skillsCombinedCommitment
        });

        return publicInputs;
    }

}