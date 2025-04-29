pragma solidity ^0.8.17;

import "forge-std/Script.sol";

/// @dev - ZK (Ultraplonk) circuit, which is generated in Noir.
import { UltraVerifier } from "../../../contracts/circuit/ultra-verifier/plonk_vk.sol"; /// @dev - Deployed-Verifier SC, which was generated based on the main.nr
import { JobTitlesAndSkillsProofVerifier } from "../../../contracts/circuit/JobTitlesAndSkillsProofVerifier.sol";


/**
 * @notice - Deployment script to deploy all SCs at once - on Sonic Blaze Testnet
 * @dev - [CLI]: Using the CLI, which is written in the bottom of this file, to deploy all SCs
 */
contract DeploymentAllContracts is Script {
    UltraVerifier public verifier;
    JobTitlesAndSkillsProofVerifier public jobTitlesAndSkillsProofVerifier;

    function setUp() public {}

    function run() public {

        //vm.createSelectFork('swellchain-testnet'); // [NOTE]: Commmentout due to the error of the "Multi chain deployment does not support library linking at the moment"

        uint256 deployerPrivateKey = vm.envUint("PHAROS_TESTNET_PRIVATE_KEY");
        //uint256 deployerPrivateKey = vm.envUint("LOCALHOST_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        //vm.startBroadcast();

        /// @dev - Deploy SCs
        verifier = new UltraVerifier();
        jobTitlesAndSkillsProofVerifier = new JobTitlesAndSkillsProofVerifier(verifier);


        vm.stopBroadcast();

        /// @dev - Logs of the deployed-contracts on Pharos Testnet
        console.logString("Logs of the deployed-contracts on Pharos Testnet");
        console.logString("\n");
        console.log("%s: %s", "UltraVerifier SC", address(verifier));
        console.logString("\n");
        console.log("%s: %s", "JobTitlesAndSkillsProofVerifier SC", address(jobTitlesAndSkillsProofVerifier));
    }
}



/////////////////////////////////////////
/// CLI (icl. SC sources) - New version
//////////////////////////////////////

// forge script script/DeploymentAllContracts.s.sol --broadcast --private-key ${PHAROS_TESTNET_PRIVATE_KEY} \
//     ./circuits/target/contract.sol:UltraVerifier \
//     ./Starter.sol:Starter --skip-simulation
