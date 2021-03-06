pragma solidity >0.4.23 <0.7.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

import "./Regulator.sol";
import "./Proposal.sol";
import "./ISA.sol";

/// @notice An ISA factory providing the interface for creation of new ISAs
contract ISAFactory is Ownable {

  Regulator private regulator;
  Proposal[] private proposals;
  ISA[] private isas;

  constructor(Regulator _regulator) public {
    regulator = _regulator;
  }

  /**
   * @dev Creates new ISA proposal which is given to Regulator for approval
   *
   * Returns a boolean value and message indicating whether the operation
   * succeeded and why.
   */
  function newProposal(
    address _lenderAddress,
    address _borrowerAddress,
    uint256 _isaAmount,
    uint256 _incomePercentage,
    uint256 _timePeriod,
    uint256 _minimumIncome,
    uint256 _paymentCap,
    string calldata _symbol
  )
    external
  {
    Proposal proposal = new Proposal(_lenderAddress, _borrowerAddress,
      _isaAmount, _incomePercentage, _timePeriod, _minimumIncome,
      _paymentCap, _symbol, regulator);

    proposals.push(proposal);
  }

  function getRegulatorAddress() external view returns(address) {
    return regulator.owner();
  }

  function getUsersProposalNumber() public view returns (uint256) {
    uint256 j = 0;
    for (uint256 i = 0 ; i < proposals.length ; i++) {
      if (proposals[i].lenderAddress() == msg.sender || proposals[i].borrowerAddress() == msg.sender) {
        j++;
      }
    }
    return j;
  }

  function getUsersProposals() external view returns (Proposal[] memory coll) {
    coll = new Proposal[](getUsersProposalNumber());

    uint256 j = 0;
    for (uint256 i = 0 ; i < proposals.length ; i++) {
      if (proposals[i].lenderAddress() == msg.sender || proposals[i].borrowerAddress() == msg.sender) {
          coll[j] = proposals[i];
          j++;
      }
    }

    return coll;
  }

  function getUsersISANumber() public view returns (uint256) {
    uint256 j = 0;
    for (uint256 i = 0 ; i < isas.length ; i++) {
      if (isas[i].isLender(msg.sender) || isas[i].isBorrower(msg.sender)) {
        j++;
      }
    }
    return j;
  }

  function getUsersISAs() external view returns (ISA[] memory coll) {
    coll = new ISA[](getUsersISANumber());

    uint256 j = 0;
    for (uint256 i = 0 ; i < isas.length ; i++) {
      if (isas[i].isLender(msg.sender) || isas[i].isBorrower(msg.sender)) {
          coll[j] = isas[i];
          j++;
      }
    }

    return coll;
  }

  function getAllProposalNumber() public view returns (uint256) {
    return proposals.length;
  }

  function getAllProposals() external view returns (Proposal[] memory coll)
  {
    coll = new Proposal[](proposals.length);

    for (uint256 i = 0 ; i < proposals.length ; i++) {
        coll[i] = proposals[i];
    }

    return coll;
  }

  function getAllISANumber() public view returns (uint256) {
    return isas.length;
  }

  function getAllISAs() external view returns (ISA[] memory coll)
  {
    coll = new ISA[](isas.length);

    for (uint256 i = 0 ; i < isas.length ; i++) {
        coll[i] = isas[i];
    }

    return coll;
  }

  function getAllAgreedProposalNumber() public view returns (uint256) {
    uint256 j = 0;
    for (uint256 i = 0 ; i < proposals.length ; i++) {
      if (proposals[i].bothAgree()) {
        j++;
      }
    }
    return j;
  }

  function getAllAgreedProposals() external view returns (Proposal[] memory coll) {
    coll = new Proposal[](getAllAgreedProposalNumber());

    uint256 j = 0;
    for (uint256 i = 0 ; i < proposals.length ; i++) {
      if (proposals[i].bothAgree()) {
        coll[j] = proposals[i];
        j++;
      }
    }

    return coll;
  }

  /**
   * @dev Creates a new ISA
   */
  function newISA(
    address payable _lenderAddress,
    address payable _borrowerAddress,
    uint256 _isaAmount,
    uint256 _incomePercentage,
    uint256 _timePeriod,
    uint256 _minimumIncome,
    uint256 _paymentCap,
    string memory _symbol
  ) public onlyOwner {
    ISA isa = new ISA(_lenderAddress, _borrowerAddress,
      _isaAmount, _incomePercentage, _timePeriod, _minimumIncome,
      _paymentCap, _symbol, regulator);

    isas.push(isa);
  }
}
